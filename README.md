# sunny-side

sunny-side is a minimal, pure-Lisp Gherkin engine that parses a
`.feature` file and turns each `Scenario` into an ordinary FiveAM
test, with no Ruby, no wire protocol, and no subprocess involved. A
project's `.feature` file stays the human- and LLM-readable spec, and
is also literally what runs, rather than documentation sitting next
to a separately maintained test suite.

## Naming

QA already has a name for a happy-path scenario: a "sunny day
scenario." That is the whole naming story. (A diner-themed origin
story involving gherkins on a plate with a burger and fries at 5am
exists too, for anyone who asks, but the name needed to mean
something to a stranger who had never heard it.)

## Why this exists instead of a Cucumber wire-protocol client

`antifuchs/clucumber` implements only the Lisp side of the Cucumber
wire protocol. Something still has to parse `.feature` files and
drive that protocol over a socket, and that something is the Ruby
`cucumber` gem itself, not an optional add-on layered on top of it.
Depending on `clucumber` therefore means pulling in a second language
toolchain (`Gemfile`, `bundle install`, a Ruby subprocess) just to
run tests for a Lisp project. sunny-side trades away real
Cucumber-tooling compatibility in exchange for staying inside one
toolchain: whatever is already running Roswell and SBCL is enough to
run these tests as well.

## Supported Gherkin subset

`Feature`, `Background`, `Scenario`, and `Given`/`When`/`Then`/`And`/
`But` steps, with `#`-comments and blank lines ignored.

**Not supported:** `Scenario Outline`/`Examples` tables, data tables,
doc strings, and tags. Adding support for any of these means
extending the parser in `src/sunny-side.lisp` directly, since the
parser is deliberately small and single-file, with no separate
configuration surface to extend instead.

## Usage

```lisp
;; steps.lisp
(sunny-side:Given! "^a fresh counter$" ()
  (setf *count* 0))

(sunny-side:When! "^I increment it$" ()
  (incf *count*))

(sunny-side:Then! "^the count should be (\\d+)$" (expected)
  (fiveam:is (= (parse-integer expected) *count*)))

(sunny-side:define-feature-tests
    #.(asdf:system-relative-pathname :my-project "features/counter.feature")
  :suite my-project-gherkin-suite)

(defun run-bdd ()
  (fiveam:run! 'my-project-gherkin-suite))
```

The keyword a step is written under (`Given`, `When`, `Then`, `And`,
or `But`) is cosmetic. Matching happens by regex text alone, the same
way real Cucumber matches steps, so an `And`-continuation of a prior
step matches whichever registered regex fits its text, not a
type-specific one tied to the keyword above it.

## Documentation

```sh
ros -e '(asdf:load-system :sunny-side/docs)(sunny-side/docs:generate)'
```

This renders `@SUNNY-SIDE-MANUAL`, defined in `src/docs.lisp`,
through `40ants-doc`. The keyword arguments `40ants-doc:document`
accepts have changed across that library's history, so anyone wiring
this into a CI pipeline should confirm the current signature locally
first.

## Testing

```sh
ros -e '(ql:quickload :sunny-side/tests)' -e '(sunny-side/tests:run-tests)'
```

The suite is a self-contained smoke test (`t/counter.feature`) that
dogfoods the engine against its own repository rather than relying
only on consuming projects to exercise it.

## Status

Extracted from `denzuko/bknr.hashkv`, where sunny-side began as the
BDD layer for that project's own `.feature` file before being split
out into its own repository; `bknr.hashkv` remains the reference
consumer. Every symbol here is code this project owns rather than a
guess at a third-party API, which is a materially lower risk profile
than the `clucumber` integration this engine replaced.

## License

BSD 3-Clause. See `LICENSE`.
