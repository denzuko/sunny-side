# sunny-side

A minimal, pure-Lisp Gherkin engine. Parses a `.feature` file and
turns each `Scenario` into an ordinary FiveAM test. No Ruby, no wire
protocol, no subprocess: your `.feature` file stays the human- and
LLM-readable spec, and is also literally what runs, not documentation
sitting next to a separately maintained test suite.

## Naming

A happy-path scenario is already called a "sunny day scenario" in QA.
That's the whole name. (There's a diner-themed origin story involving
gherkins on a plate with a burger and fries at 5am, if you ask, but
the name should mean something to a stranger who's never heard it.)

## Why this exists instead of a Cucumber wire-protocol client

`antifuchs/clucumber` implements only the Lisp side of the Cucumber
wire protocol. Something still has to parse `.feature` files and
drive it over a socket, and that's the Ruby `cucumber` gem itself,
not an optional add-on. That means a second language toolchain
(`Gemfile`, `bundle install`, a Ruby subprocess) just to run tests for
a Lisp project. `sunny-side` trades real Cucumber-tooling
compatibility for staying inside one toolchain: whatever's already
running Roswell/SBCL is enough to run these tests too.

## Supported Gherkin subset

`Feature`, `Background`, `Scenario`, and `Given`/`When`/`Then`/`And`/
`But` steps. `#`-comments and blank lines are ignored.

**Not supported**: `Scenario Outline`/`Examples` tables, data tables,
doc strings, tags. Adding any of these means extending the parser in
`src/sunny-side.lisp` directly; the parser is small and single-file on
purpose, with no separate configuration surface.

## Usage

```lisp
;; steps.lisp
(sunny-side:Given "^a fresh counter$" ()
  (setf *count* 0))

(sunny-side:When "^I increment it$" ()
  (incf *count*))

(sunny-side:Then "^the count should be (\\d+)$" (expected)
  (fiveam:is (= (parse-integer expected) *count*)))

(sunny-side:define-feature-tests
    #.(asdf:system-relative-pathname :my-project "features/counter.feature")
  :suite my-project-gherkin-suite)

(defun run-bdd ()
  (fiveam:run! 'my-project-gherkin-suite))
```

The keyword a step is written under (`Given`/`When`/`Then`/`And`/`But`)
is cosmetic. Matching is by regex text alone, the same as real
Cucumber, so `And`-continuations of a prior step type match whatever
regex fits, not a type-specific one.

## Documentation

```sh
ros -e '(asdf:load-system :sunny-side/docs)(sunny-side/docs:generate)'
```

Renders `@SUNNY-SIDE-MANUAL` (defined in `src/docs.lisp`) via
`40ants-doc`. The exact keyword arguments accepted by
`40ants-doc:document` have changed across that library's history.
Confirm the current signature locally before wiring this into CI.

## Status

Extracted from `denzuko/bknr.hashkv`, where it was the BDD layer for
that project's own `.feature` file before being split out as its own
repo. `bknr.hashkv` is the reference consumer.

Untested in the environment this was written in: no SBCL/Quicklisp
available to actually run it. Every symbol here is code this project
owns rather than a guess at a third-party API, which is a materially
lower risk profile than the clucumber integration this replaced, but
it still deserves a real run before being trusted in CI.

## License

BSD 3-Clause. See `LICENSE`.
