;;;; src/docs.lisp
;;;;
;;;; sunny-side's manual, defined with 40ants-doc, rendered with
;;;; 40ants-doc-full/builder:render-to-string (verified against an
;;;; actual installed copy; the system that has DOCUMENT does not
;;;; exist under that name).

(defpackage :sunny-side/docs
  (:use :cl)
  (:import-from #:40ants-doc #:defsection)
  (:import-from #:40ants-doc-full/builder #:render-to-string)
  (:export #:@sunny-side-manual
           #:generate))

(in-package :sunny-side/docs)

(defsection @sunny-side-manual (:title "sunny-side")
  "A minimal, pure-Lisp Gherkin engine: parses a .feature file and
turns each Scenario into an ordinary FiveAM test."
  (sunny-side:Given! macro)
  (sunny-side:When! macro)
  (sunny-side:Then! macro)
  (sunny-side:And! macro)
  (sunny-side:But! macro)
  (sunny-side:register-step function)
  (sunny-side:find-and-run-step function)
  (sunny-side:parse-feature function)
  (sunny-side:feature-scenario class)
  (sunny-side:define-feature-tests macro))

(defun generate (&optional (stream *standard-output*) (format :markdown))
  "Renders @SUNNY-SIDE-MANUAL to STREAM in FORMAT (:markdown or :html)."
  (write-string (render-to-string @sunny-side-manual :format format) stream))
