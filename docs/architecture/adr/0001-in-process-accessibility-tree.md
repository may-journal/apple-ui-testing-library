---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# 0001 — Tests read the accessibility tree in-process

## Context

XCUITest pays an app launch per test, and ViewInspector skips rendering. May Calendar's in-process harness ran at 0.06 to 1.8 s per test ([hub#54](https://github.com/may-journal/hub/issues/54)).

## Decision

1. Tests run in a bundle hosted by the app, in the app's process.
2. `Screen` draws the root view in a `UIHostingController` on a key `UIWindow` of the host's scene.
3. Tests read `accessibilityElements` and drive what VoiceOver drives: `accessibilityActivate()`, custom actions, `accessibilityScroll(_:)`, `accessibilityPerformEscape()`, and the keyboard.
4. The library never reads view types, view models, or stores.

## Consequences

1. No launch per test, so a wide integration suite stays fast.
2. The `@main` App, its `WindowGroup`, and real permission prompts are left to a consumer's own XCUITest smoke test.
3. An element VoiceOver cannot reach cannot be tested, which surfaces accessibility bugs early.
