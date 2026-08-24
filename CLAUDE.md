# CLAUDE.md

Hand-authored. `denzuko/dps-meta@v1` was tried as the CI-driven
generator for this file but has a confirmed upstream bug. Its
"Checkout dps-meta source" step fetches a `v4` ref that doesn't exist
in that repo, failing unconditionally for every consumer regardless
of configuration. `.github/workflows/ci.yml` runs real, working CI
instead (smoke-test suite, docs build) via a plain Roswell/qlot
install, matching `denzuko/edm-engine`'s proven pattern. This file
remains a hand-authored placeholder; regenerate via `dps-meta` once
its upstream bug is fixed, or hand-maintain it going forward.

## Project Identity

| Field        | Value |
|--------------|-------|
| Application  | sunny-side |
| Description  | Minimal pure-Lisp Gherkin engine: parses .feature files and runs each Scenario as an ordinary FiveAM test |
| Type         | Common Lisp library |
| Version      | 1.0.0 |
| Branch       | develop |
| Licence      | BSD-3-Clause |
| Organisation | denzuko |

## Standards Stack

- BSD-3-Clause license
- git-flow branching, `develop` as the integration branch
- Semver: MAJOR = public API/interface break only; MINOR = new non-breaking capability; PATCH = everything else
- 40ants-doc for documentation (`sunny-side/docs`)

## BDD Workflow

`t/counter.feature` + `t/test.lisp` (system `sunny-side/tests`) is a
self-contained smoke test: a tiny counter feature, parsed and run as
real FiveAM tests through `define-feature-tests`, dogfooding the
engine on its own repo, not just through consumers. Also dogfoods via
consuming projects' own `.feature` files, starting with
`denzuko/bknr.hashkv`'s `bdd.ros`.

## Subcommands

None. This is a library with no `.ros` entry point.

## Do Not

- Do not extend the supported Gherkin subset (Scenario Outline, data
  tables, doc strings, tags) without updating
  `src/sunny-side.lisp`'s parser directly. There is no configuration
  surface for this, by design (see README).
- Do not conflate this with a Cucumber wire-protocol implementation.
  It has no Ruby dependency and no compatibility goal with `.feature`
  files that rely on unsupported Gherkin constructs.
