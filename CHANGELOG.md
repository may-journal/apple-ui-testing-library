---
relatedConfigurations: ['.fitnessrc.json']
---

# Changelog

## Changes

### 2026.10.10.1404

- Docs: `docs/usage.md` guides setup with XcodeGen and a checked-in project, on iOS and macOS
- Docs: the guide shows every query, action and wait with an example from the real API
- Docs: it states the serialized-suite rule, what a failure looks like, and the system-menu gap
- Docs: the README links to the guide and its Setup, and no longer restates it
- Docs: the workflows README says the `requirements` check is already on

### 2026.10.10.1310

- Feat: `make requirements-coverage` runs both bundles with coverage on and prints line coverage of `Sources/UITestingLibrary/` for iOS, macOS and both
- Fix: coverage comes from each run's profile through `llvm-cov`, since Xcode leaves the package's static code out of `.xcresult` coverage
- Chore: a line counts once across platforms, and fixtures and tests are left out
- Docs: the code doc's Tests table names the coverage target

### 2026.10.10.1244

- Fix: a tap that opens nothing fails saying a system menu needs a touch tool
- Docs: the README states the gap for system menus and pairs an XCUITest smoke test with it
- Chore: `make requirements` collects no simulator diagnostics, and shuts its simulator down by UDID
- Fix: a tap on many matches says how many match, and a pressed control counts only when something listens
- Docs: AGENTS.md drops consumer setup, which the kickoff doc already states

### 2026.10.10.1239

- Feat: `Screen.render` draws a root in a key window on iOS and macOS, and `User` reads it as VoiceOver does
- Feat: `User` finds by role and label, text, then identifier, and taps, chooses, types, scrolls and goes back
- Feat: every look and act waits on a condition up to a deadline, and fails with a `Failure` naming the test's line
- Feat: automation turns on once per process on each platform, and the canary fails a screen that read nothing
- Docs: ADRs 0004, 0005 and 0006 record the Mac switch, closing on a second render, and thrown failures

### 2026.10.10.1238

- Docs: ADR 0006 puts one API over two backends, UIKit on iOS and AppKit on macOS; the C4 docs show both hosts
- Docs: Platforms states iOS 26 and macOS 26 and later, and requirement 0001 gains a Mac acceptance
- Feat: `Package.swift` ships the `UITestingLibrary` product for iOS and macOS with a Swift 6 skeleton of the public types
- Feat: `project.yml` generates an iOS and a macOS SwiftUI test host, each with a hosted test bundle on the package
- Feat: `make requirements` builds and runs both bundles from one DerivedData path, and SwiftLint runs through fitness

### 2026.10.10.1212

- Feat: `cspell.json` lists the org's app names as `flagWords`, so fitness fails any file that uses one
- Feat: the one-word spellings of those names are listed too
- Docs: AGENTS.md links to the rule instead of restating the names

### 2026.10.10.1056

- Docs: the architecture docs and ADRs describe consumers generically, with no app names
- Docs: the hub research link stays only where it is cited as a source
- Docs: an earlier entry about platform support no longer names an app

### 2026.10.10.1045

- Docs: support iOS 26 and later, built with Xcode 27, so apps on those versions can adopt the library
- Docs: the code doc's Platforms section is the one place that states supported versions
- Docs: the README, AGENTS.md, and the kickoff doc link to Platforms instead of restating it

### 2026.10.10.1041

- Docs: add five architecture templates in docs/architecture/templates, one per doc shape
- Docs: the C4 diagram levels share one template; code, journey, kickoff, and README each have their own
- Docs: fitness 1.4.0 fails any architecture doc whose sections match none of the templates

### 2026.10.10.0955

- Docs: add a requirements template, so fitness fails any requirement doc whose sections drift
- Chore: add the org pull request template, since the private org copy is no default here
- Docs: the requirements template guides IDs, Given, When, Then, and one owning test per acceptance

### 2026.10.10.0953

- Docs: add the org ADR template, with a short context, numbered decisions, and numbered consequences
- Docs: title the five ADRs by number alone and drop their status lines
- Docs: cut each ADR's context to tweet length and number its consequences

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
