---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 00 — Kickoff questions

Product framing for apple-ui-testing-library: Testing Library's guiding principles, on Apple platforms.

## What it is

A Swift package, module `UITestingLibrary`, that a test target imports. It draws the app's real root view in a window of the app hosting the tests. Tests then find what is on screen by what VoiceOver says, and act through VoiceOver's own entry points.

The research behind it is [may-journal/hub#54](https://github.com/may-journal/hub/issues/54). It generalizes an existing in-process requirements harness.

## Who it's for

Two users, as Testing Library names them. The person on screen, whose view the tests take. The developer composing the app root, who writes the tests.

A consumer adds the package to its test targets through XcodeGen `packages:` with `majorVersion: 1`.

## Principles

- "The more your tests resemble the way your software is used, the more confidence they can give you." ([Testing Library](https://testing-library.com/docs/guiding-principles/))
- The accessibility tree is the DOM. Queries read labels, values, and traits; view types and view models stay unseen.
- Apple frameworks only: UIKit, SwiftUI, XCTest, and Swift Testing, on the versions in [Platforms](04-code.md#platforms).
- A failure says what VoiceOver reads on screen, so the fix starts from what a person sees.
