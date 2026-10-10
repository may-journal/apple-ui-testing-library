---
relatedConfigurations: ['.fitnessrc.json']
---

# Changelog

## Changes

### 2026.10.10.0949

- Docs: add five requirement docs, from showing the app to reading a failure, with 24 acceptances
- Docs: each requirement names Plan issue 1 as its measurement source until tests land
- Docs: the requirements check stays off until tests prove each acceptance

### 2026.10.10.0949

- Docs: drop `TestClock` from the components, code, journey, and ADR 0003; each app owns its clock
- Docs: a settle polls until two reads of the tree match, with animations off, under a deadline
- Docs: renumber the component callouts to match the table

### 2026.10.10.0946

- Docs: a settle polls until two reads of the tree match, under a deadline
- Docs: taps reach toggles, tabs, and fields; Swift Testing suites share one serialized parent
- Docs: the code layers show waits reading the tree and reports, and the journey ends in a pass

### 2026.10.10.0944

- Chore: scaffold the repo with a Plan issue template, a Makefile, and a commented .gitignore
- Docs: add AGENTS.md, with CLAUDE.md linked to it, and a README crediting Testing Library
- Docs: describe the org-synced workflows and the PR and plan formats in a workflows README

### 2026.10.10.0943

- Docs: add C4 architecture docs for the planned `UITestingLibrary` module
- Docs: record ADRs for the in-process tree, query priority, and condition waits
- Docs: record ADRs for the automation canary and one key window per process
- Chore: add the fitness config and cspell words the docs need
