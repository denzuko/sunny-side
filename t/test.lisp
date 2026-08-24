;;;; t/test.lisp
;;;;
;;;; Formalizes the same logic verified interactively via Swank
;;;; earlier: a tiny counter .feature file, parsed and run as real
;;;; FiveAM tests through DEFINE-FEATURE-TESTS.

(defpackage :sunny-side/tests
  (:use :cl :sunny-side)
  (:export #:run-tests))

(in-package :sunny-side/tests)

(defvar *counter* 0)

(Given! "^a fresh counter$" ()
  (setf *counter* 0))

(When! "^I increment it$" ()
  (incf *counter*))

(Then! "^the count should be (\\d+)$" (expected)
  (fiveam:is (= (parse-integer expected) *counter*)))

(define-feature-tests
    #.(asdf:system-relative-pathname :sunny-side/tests "t/counter.feature")
  :suite sunny-side-suite)

(defun run-tests ()
  "Runs sunny-side's own smoke-test suite and returns T if every
scenario passed."
  (fiveam:run! 'sunny-side-suite))
