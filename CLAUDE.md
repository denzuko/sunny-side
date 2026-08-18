# CLAUDE.md

Hand-authored — the `dps-meta` generator was not available in the
environment this repo was scaffolded in. Regenerate via `dps-meta`
when convenient; this file should be treated as a placeholder for
that, not a permanent hand-maintained document.

## Project Identity

| Field        | Value |
|--------------|-------|
| Application  | sunny-side |
| Description  | Minimal pure-Lisp Gherkin engine — parses .feature files and runs each Scenario as an ordinary FiveAM test |
| Type         | Common Lisp library |
| Version      | 1.0.0 |
| Branch       | develop |
| Licence      | BSD-3-Clause |
| Organisation | denzuko |

## Standards Stack

- BSD-3-Clause license
- git-flow branching, `develop` as the integration branch
- Semver: MAJOR = public API/interface break only; MINOR = new non-breaking capability; PATCH = everything else

## BDD Workflow

Dogfoods itself once a consuming project exercises it against its own
`.feature` file — see `denzuko/bknr.hashkv`'s `bdd.ros` for the
reference usage. This repo has no `.feature` file of its own yet.

## Subcommands

None — this is a library with no `.ros` entry point.

## Do Not

- Do not extend the supported Gherkin subset (Scenario Outline,
  data tables, doc strings, tags) without updating
  `src/sunny-side.lisp`'s parser directly — there is no
  configuration surface for this, by design (see README).
- Do not conflate this with a Cucumber wire-protocol implementation
  — it has no Ruby dependency and no compatibility goal with
  `.feature` files that rely on unsupported Gherkin constructs.
