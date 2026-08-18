;;;; src/docs.lisp
;;;;
;;;; sunny-side's manual, defined with 40ants-doc.
;;;;
;;;; NOTE: 40ants-doc:document's exact keyword arguments have changed
;;;; across that library's history. Confirm the current signature
;;;; locally before relying on this in CI.

(defpackage :sunny-side/docs
  (:use :cl)
  (:import-from #:40ants-doc #:defsection #:document)
  (:export #:@sunny-side-manual
           #:generate))

(in-package :sunny-side/docs)

(defsection @sunny-side-manual (:title "sunny-side")
  "A minimal, pure-Lisp Gherkin engine: parses a .feature file and
turns each Scenario into an ordinary FiveAM test."
  (sunny-side:Given macro)
  (sunny-side:When macro)
  (sunny-side:Then macro)
  (sunny-side:And macro)
  (sunny-side:But macro)
  (sunny-side:register-step function)
  (sunny-side:find-and-run-step function)
  (sunny-side:parse-feature function)
  (sunny-side:feature-scenario class)
  (sunny-side:define-feature-tests macro))

(defun generate (&optional (stream *standard-output*) (format :markdown))
  "Renders @SUNNY-SIDE-MANUAL to STREAM in FORMAT (:markdown or :html)."
  (document @sunny-side-manual :stream stream :format format))
