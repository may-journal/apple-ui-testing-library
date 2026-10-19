---
relatedConfigurations: ['.fitnessrc.json']
---

# Changelog

## Changes

## [1.7.0](https://github.com/may-journal/apple-ui-testing-library/compare/v1.6.0...v1.7.0) (2026-10-19)


### Features

* **gestures:** drag any element by a distance, slowly or as a flick ([#84](https://github.com/may-journal/apple-ui-testing-library/issues/84)) ([c459542](https://github.com/may-journal/apple-ui-testing-library/commit/c4595423f6c16899adf408f5c4b44d1a635e2097))

## [1.6.0](https://github.com/may-journal/apple-ui-testing-library/compare/v1.5.0...v1.6.0) (2026-10-18)


### Features

* **gestures:** pinch, any character key, and shortcuts with no field ([#79](https://github.com/may-journal/apple-ui-testing-library/issues/79)) ([ad739ef](https://github.com/may-journal/apple-ui-testing-library/commit/ad739ef8a2d34abc5776f5217511800cdd58f959))

## [1.5.0](https://github.com/may-journal/apple-ui-testing-library/compare/v1.4.0...v1.5.0) (2026-10-18)


### Features

* **actions:** every common person action, in process and off screen ([#71](https://github.com/may-journal/apple-ui-testing-library/issues/71)) ([e90b014](https://github.com/may-journal/apple-ui-testing-library/commit/e90b0140c08bd976f7870f987e7f136f7fa8a4c9))

## [1.4.0](https://github.com/may-journal/apple-ui-testing-library/compare/v1.3.0...v1.4.0) (2026-10-18)


### Features

* **actions:** press keys, watch for a set time and see the share sheet ([#66](https://github.com/may-journal/apple-ui-testing-library/issues/66)) ([166b54d](https://github.com/may-journal/apple-ui-testing-library/commit/166b54da6508057584bf565bf9f541d2a8907a0a))

## [1.3.0](https://github.com/may-journal/apple-ui-testing-library/compare/v1.2.0...v1.3.0) (2026-10-13)


### Features

* **guard:** flag app names with cspell flagWords ([#17](https://github.com/may-journal/apple-ui-testing-library/issues/17)) ([2b82575](https://github.com/may-journal/apple-ui-testing-library/commit/2b82575cab1e4ecb09ba205c6d7b75f0a8d6db8e))
* **library:** one API over UIKit and AppKit, with tests for every acceptance ([#18](https://github.com/may-journal/apple-ui-testing-library/issues/18)) ([f29742f](https://github.com/may-journal/apple-ui-testing-library/commit/f29742f2d84ad814a52ed740b6cf5177d58478fd))
* **screen:** drive menus and render at a text size and appearance ([#50](https://github.com/may-journal/apple-ui-testing-library/issues/50)) ([358c873](https://github.com/may-journal/apple-ui-testing-library/commit/358c87345acf27e02e5bb625171a2c2551cacbfc))
* **system:** drive system sharing, Siri and disabled controls ([#60](https://github.com/may-journal/apple-ui-testing-library/issues/60)) ([ad97d28](https://github.com/may-journal/apple-ui-testing-library/commit/ad97d287cb33bb690ebd1612069a3c1127e1ca6c))


### Bug Fixes

* **tree:** open a navigation bar's menu on both platforms ([#56](https://github.com/may-journal/apple-ui-testing-library/issues/56)) ([7c8e233](https://github.com/may-journal/apple-ui-testing-library/commit/7c8e233fa2697fbc6524687d9a7b45e5692b40dc))
* **tree:** read and press alerts and confirmation dialogs as Designed for iPad ([#32](https://github.com/may-journal/apple-ui-testing-library/issues/32)) ([6bd667f](https://github.com/may-journal/apple-ui-testing-library/commit/6bd667f25334b943f08f3f35b06eb0ab3792c5c8))


### Performance Improvements

* **waits:** settle on the idle run loop and reuse reads ([#38](https://github.com/may-journal/apple-ui-testing-library/issues/38)) ([d610ca7](https://github.com/may-journal/apple-ui-testing-library/commit/d610ca769657b6ec3d03a6ce19de75ed0d721c2e))

## [1.2.0](https://github.com/may-journal/apple-ui-testing-library/compare/v1.1.1...v1.2.0) (2026-10-13)


### Features

* **system:** drive system sharing, Siri and disabled controls ([#60](https://github.com/may-journal/apple-ui-testing-library/issues/60)) ([ad97d28](https://github.com/may-journal/apple-ui-testing-library/commit/ad97d287cb33bb690ebd1612069a3c1127e1ca6c))

### 2026.10.12.2157

- Feat: an `Element` reports `isEnabled`, menu items included, and any tap on a disabled control fails saying so
- Feat: the optional `UITestingLibrarySystem` product drives a real share sheet into a local destination and checks the delivered image and message
- Feat: a `SystemSession` asks Siri a phrase and checks its visible answer, keeping the phrase, answer and test line in failures
- Chore: `make requirements-e2e` runs the system tests on a simulator you own, while `make requirements` stays native
- Docs: requirements 0006 to 0008, ADRs 0007 to 0009, the usage guide's System UI section, and architecture views that name every source

## [1.1.1](https://github.com/may-journal/apple-ui-testing-library/compare/v1.1.0...v1.1.1) (2026-10-12)


### Bug Fixes

* **tree:** open a navigation bar's menu on both platforms ([#56](https://github.com/may-journal/apple-ui-testing-library/issues/56)) ([7c8e233](https://github.com/may-journal/apple-ui-testing-library/commit/7c8e233fa2697fbc6524687d9a7b45e5692b40dc))

### 2026.10.12.1622

- Fix: a tap on a navigation bar's menu button opens its menu as Designed for iPad, through its primary action, unless disabled
- Fix: the Mac reads a window's toolbar before its content, so a navigation stack's toolbar items can be found and tapped
- Fix: the Mac window keeps the test's size, where SwiftUI shrank it to fit and hid toolbar items in an overflow menu
- Test: 0003.7 now drives a menu in the content and one in the navigation bar, on both platforms
- Docs: the usage guide links 0003.7, and the code doc says how a navigation bar's menu is reached

## [1.1.0](https://github.com/may-journal/apple-ui-testing-library/compare/v1.0.1...v1.1.0) (2026-10-12)


### Features

* **screen:** drive menus and render at a text size and appearance ([#50](https://github.com/may-journal/apple-ui-testing-library/issues/50)) ([358c873](https://github.com/may-journal/apple-ui-testing-library/commit/358c87345acf27e02e5bb625171a2c2551cacbfc))

### 2026.10.12.1322

- Feat: a tap on a menu control opens its menu, `reads()` returns its items, and `goesBack()` closes it
- Feat: `Screen.render(look:)` takes a `Look` with a text size and a light or dark appearance, each overriding the system's for that root
- Fix: the Mac reads a menu button's attributed title as a button, and a submenu item tap fails, as on iOS
- Test: 0003.7 drives a menu, an expect checks the spoken read, and 0003.8 goes back out of it; 0001.8 to 0001.10 cover layouts, text size and appearance
- Docs: the usage guide and README cover menus and `Look`, and ADR 0001 and the code doc say how menus are reached

## [1.0.1](https://github.com/may-journal/apple-ui-testing-library/compare/v1.0.0...v1.0.1) (2026-10-12)


### Performance Improvements

* **waits:** settle on the idle run loop and reuse reads ([#38](https://github.com/may-journal/apple-ui-testing-library/issues/38)) ([d610ca7](https://github.com/may-journal/apple-ui-testing-library/commit/d610ca769657b6ec3d03a6ce19de75ed0d721c2e))

### 2026.10.12.0845

- Perf: a look or an act reuses the last read, and a read takes frames first and reads off-screen elements late
- Perf: the Mac reader skips a leaf's children, and the iOS reader asks once whether it runs on a Mac
- Test: 0001.7 and 0004.5 promise read and act times on a long fixture whose rows offer Archive
- Chore: `make requirements-timing` prints its table even after a failing test, with phase names in `config/timing-phases.json`
- Docs: the Makefile's logic moves to `scripts/`, and ADR 0005 notes that parallel testing gains nothing

## 1.0.0 (2026-10-10)


### Features

* **guard:** flag app names with cspell flagWords ([#17](https://github.com/may-journal/apple-ui-testing-library/issues/17)) ([2b82575](https://github.com/may-journal/apple-ui-testing-library/commit/2b82575cab1e4ecb09ba205c6d7b75f0a8d6db8e))
* **library:** one API over UIKit and AppKit, with tests for every acceptance ([#18](https://github.com/may-journal/apple-ui-testing-library/issues/18)) ([f29742f](https://github.com/may-journal/apple-ui-testing-library/commit/f29742f2d84ad814a52ed740b6cf5177d58478fd))


### Bug Fixes

* **tree:** read and press alerts and confirmation dialogs as Designed for iPad ([#32](https://github.com/may-journal/apple-ui-testing-library/issues/32)) ([6bd667f](https://github.com/may-journal/apple-ui-testing-library/commit/6bd667f25334b943f08f3f35b06eb0ab3792c5c8))

### 2026.10.10.1606

- Feat: as Designed for iPad, the iOS backend reads alerts and confirmation dialogs from UIKit's hidden copy
- Feat: tapping one of that alert's enabled buttons runs its handler through the alert, as a click on the Mac's alert does
- Fix: the Mac backend counts a press that closes an alert sheet, since its button answers false
- Docs: 0003.6 states the acceptance, and the code doc's Platforms table names the alert copy

### 2026.10.10.1542

- Test: the iOS bundle runs natively as Designed for iPad, and the Makefile drops its simulator lookup and shutdown
- Chore: the iOS hosts sign with a development team, since the iOS 27 SDK refuses ad hoc
- Fix: only the iOS run may update provisioning, so the macOS build never contacts the developer portal
- Fix: both hosts carry version keys, which installing as Designed for iPad requires
- Docs: the code doc's Platforms and Tests tables describe the native iOS run; 0001.1 keeps its compact phone layout

### 2026.10.10.1458

- Test: both bundles compile `Tests/Shared/`, so 22 acceptances run on iOS and macOS; only the layout ones stay per platform
- Fix: the Mac tree reads attributes untyped, so a scroller's number no longer traps, and static text reads as its label
- Fix: the Mac tree reads an attached sheet alone, maps headings, and skips a group with nothing to say or offer
- Fix: `goesBack()` passes only once the settled screen changes, since SwiftUI's Mac nodes answer cancel with nothing to close
- Chore: a settle pauses once before its first compare; macOS line coverage rises from 43.5% to 93.1%

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
