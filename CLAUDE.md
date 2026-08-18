# CLAUDE.md

Hand-authored. `.github/workflows/ci.yml` invokes
`denzuko/dps-meta@v1` (`type: lisp-actor`) on GitHub's own runners,
not locally in the environment this repo was scaffolded in, where
neither SBCL nor network access to that runner exists. This file
should be treated as a placeholder until the Action actually runs
against a push to `develop` and regenerates it for real; its output
has not been observed from this environment.

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

Dogfoods itself once a consuming project exercises it against its own
`.feature` file. See `denzuko/bknr.hashkv`'s `bdd.ros` for the
reference usage. This repo has no `.feature` file of its own yet.

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
