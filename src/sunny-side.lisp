;;;; src/sunny-side.lisp
;;;;
;;;; A minimal, pure-Lisp Gherkin engine: parses a .feature file and
;;;; turns each Scenario into an ordinary FiveAM test. No Ruby, no
;;;; wire protocol, no subprocess. The .feature file stays the
;;;; human- and LLM-readable spec, and is also the thing that
;;;; actually runs, not just documentation alongside a separately
;;;; hand-written test suite.
;;;;
;;;; Sunny-side because a happy-path scenario is already called a
;;;; "sunny day scenario" in QA; the name means something to a
;;;; stranger who's never heard the diner story.
;;;;
;;;; Supported subset: Feature, Background, Scenario, and
;;;; Given/When/Then/And/But steps, with #-comments and blank lines
;;;; ignored. NOT supported: Scenario Outline/Examples tables, data
;;;; tables, doc strings, and tags. Extending any of those means
;;;; extending the parser, not a configuration change.
;;;;
;;;; Untested in this environment (no SBCL/Quicklisp available here
;;;; to run it), but every symbol in this file is code this project
;;;; owns, not a guess at a third-party library's API surface, so the
;;;; risk profile is materially lower than, say, the clucumber
;;;; integration this replaced. Still worth an actual run before
;;;; trusting it in CI.

(defpackage :sunny-side
  (:use :cl)
  (:export #:Given!
           #:When!
           #:Then!
           #:And!
           #:But!
           #:register-step
           #:find-and-run-step
           #:parse-feature
           #:feature-scenario
           #:feature-scenario-title
           #:feature-scenario-steps
           #:define-feature-tests))

(in-package :sunny-side)

;;; --- Step registry ----------------------------------------------------

(defvar *steps* nil
  "Alist of (REGEX . FUNCTION), oldest registration first. A step's
text is matched against these regexes in registration order. The
first match wins, exactly like Cucumber's own step matching. The
Given/When/Then/And/But keyword a step is written under in the
.feature file is cosmetic; matching is by regex text alone, same as
real Cucumber.")

(defun register-step (regex function)
  "Registers FUNCTION to run when a step's text matches REGEX. Capture
groups in REGEX are passed to FUNCTION as positional string arguments."
  (setf *steps* (append *steps* (list (cons regex function)))))

(defmacro define-step-keyword (name)
  "Defines a step-registration macro NAME (Given!/When!/Then!/And!/But!)
that all do the same thing (register a step under a regex), so the
Lisp code reads the same as the .feature file it implements. The
trailing ! marks these as side-effecting forms (they register into
*STEPS*), and avoids colliding with standard CL symbols: bare WHEN
and AND are CL:WHEN and CL:AND, which this package still needs for
its own ordinary conditionals below."
  `(defmacro ,name (regex (&rest capture-vars) &body body)
     `(register-step ,regex (lambda (,@capture-vars) ,@body))))

(define-step-keyword Given!)
(define-step-keyword When!)
(define-step-keyword Then!)
(define-step-keyword And!)
(define-step-keyword But!)

(defun find-and-run-step (step-text)
  "Finds the first registered step regex matching STEP-TEXT and calls
its function with the regex's capture groups. Errors if nothing matches."
  (dolist (entry *steps*)
    (multiple-value-bind (match groups)
        (cl-ppcre:scan-to-strings (car entry) step-text)
      (when match
        (return-from find-and-run-step
          (apply (cdr entry) (coerce groups 'list))))))
  (error "No step definition matches: ~S" step-text))

;;; --- .feature parsing -----------------------------------------------------

(defstruct feature-scenario
  "One Scenario: its title, and its steps as plain strings with the
leading Given/When/Then/And/But keyword already stripped."
  title steps)

(defun starts-with-p (string prefix)
  (and (>= (length string) (length prefix))
       (string= string prefix :end1 (length prefix))))

(defun step-line-p (line)
  (some (lambda (keyword) (starts-with-p line keyword))
        '("Given " "When " "Then " "And " "But ")))

(defun strip-step-keyword (line)
  (let ((space (position #\Space line)))
    (string-trim " " (subseq line (1+ space)))))

(defun blank-or-comment-p (line)
  (or (zerop (length line))
      (char= (char line 0) #\#)))

(defun parse-feature (pathname)
  "Parses PATHNAME's Feature/Background/Scenario/step structure.
Returns (VALUES BACKGROUND-STEPS SCENARIOS). BACKGROUND-STEPS is a
list of step-text strings run before every scenario; SCENARIOS is a
list of FEATURE-SCENARIO, in file order."
  (let ((background nil)
        (scenarios nil)
        (current nil)
        (in-background nil))
    (with-open-file (in pathname)
      (loop for raw = (read-line in nil nil)
            while raw
            for line = (string-trim '(#\Space #\Tab #\Return) raw)
            do (cond
                 ((blank-or-comment-p line) nil)
                 ((starts-with-p line "Feature:") nil)
                 ((starts-with-p line "Background:")
                  (setf in-background t))
                 ((starts-with-p line "Scenario:")
                  (when current
                    (setf (feature-scenario-steps current)
                          (nreverse (feature-scenario-steps current)))
                    (push current scenarios))
                  (setf current (make-feature-scenario
                                 :title (string-trim " " (subseq line (length "Scenario:")))
                                 :steps nil))
                  (setf in-background nil))
                 ((step-line-p line)
                  (let ((text (strip-step-keyword line)))
                    (cond
                      (in-background (push text background))
                      (current (push text (feature-scenario-steps current)))
                      (t (error "Step ~S appears before any Scenario or Background in ~A"
                                text pathname)))))
                 (t nil))))
    (when current
      (setf (feature-scenario-steps current)
            (nreverse (feature-scenario-steps current)))
      (push current scenarios))
    (values (nreverse background) (nreverse scenarios))))

;;; --- Wiring scenarios to FiveAM ---------------------------------------------

(defun scenario-test-name (title)
  "Turns a Scenario title into a usable Lisp symbol name."
  (intern (string-upcase (substitute #\- #\Space (remove #\" title)))))

(defmacro define-feature-tests (feature-pathname &key (suite 'gherkin-suite))
  "Parses FEATURE-PATHNAME at macroexpansion time and defines one
FiveAM test per Scenario, each running its Background steps (if any)
followed by its own steps through FIND-AND-RUN-STEP. Defines SUITE via
FIVEAM:DEF-SUITE if it doesn't already exist in this package."
  (multiple-value-bind (background scenarios) (parse-feature feature-pathname)
    `(progn
       (fiveam:def-suite ,suite :description ,(format nil "Gherkin scenarios from ~A" feature-pathname))
       (fiveam:in-suite ,suite)
       ,@(mapcar
          (lambda (scenario)
            `(fiveam:test ,(scenario-test-name (feature-scenario-title scenario))
               ,(feature-scenario-title scenario)
               (dolist (step ',(append background (feature-scenario-steps scenario)))
                 (find-and-run-step step))))
          scenarios))))
