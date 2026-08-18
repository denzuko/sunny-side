;;;; sunny-side.asd

(asdf:defsystem "sunny-side"
  :description "A minimal, pure-Lisp Gherkin engine — parses .feature files and runs each Scenario as an ordinary FiveAM test. No Ruby, no wire protocol, no subprocess."
  :author "Dwight Spencer"
  :license "BSD-3-Clause"
  :version "1.0.0"
  :depends-on ("fiveam" "cl-ppcre")
  :pathname "src/"
  :components ((:file "sunny-side")))
