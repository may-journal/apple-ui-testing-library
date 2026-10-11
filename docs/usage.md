---
relatedConfigurations: ['../.fitnessrc.json']
---

# Usage

How to test an app with `UITestingLibrary`. For supported versions see [Platforms](architecture/04-code.md#platforms).

## Setup

Add the package to a test target that your app hosts, and link it to test targets only. Both ways below work for iOS and macOS apps. Set the test target's host application to your app, so tests run in its process.

With XcodeGen, list the package and depend on it from the test target:

```yaml
packages:
  UITestingLibrary:
    url: https://github.com/may-journal/apple-ui-testing-library
    majorVersion: 1
targets:
  AppTests:
    type: bundle.unit-test
    dependencies:
      - package: UITestingLibrary
```

With a checked-in Xcode project, choose File > Add Package Dependencies and enter the same URL. Pick "Up to Next Major Version" from 1.0.0. Add the `UITestingLibrary` product to the test target. Tests then say `import UITestingLibrary`.

## Render and close a screen

`Screen.render` draws a root view in the app's key window. `close()` hides it and runs the canary check ([ADR 0004](architecture/adr/0004-automation-canary.md)). Pass `size: .pad` for an iPad layout.

```swift
let screen = try Screen.render { AppRoot() }
let user = User(screen)
// look and act here
try screen.close()
```

Rendering a second screen closes the first ([ADR 0005](architecture/adr/0005-one-window-per-process.md)).

## Queries

A `Query` names an element. Pick the first kind that fits ([ADR 0002](architecture/adr/0002-query-priority.md)). A look or act needs exactly one match on screen.

| Query | Finds |
| ----- | ----- |
| `.role(_, _)` | A role and its exact label. |
| `.button(_)` | Shorthand for the button role. |
| `.text(_)` | A label, a value, or both as VoiceOver says them. |
| `.identifier(_)` | An accessibility identifier. Use it last. |

The roles are `button`, `link`, `heading`, `image`, `text`, `textField`, `searchField`, `adjustable`, `toggle` and `selected`.

```swift
try await user.sees(.button("Save"))
try await user.sees(.role(.heading, "Groceries"))
try await user.sees(.text("Milk"))
try await user.sees(.identifier("add-bottom"))
```

`sees` returns an `Element` with `label`, `value`, `spoken`, `has(_:)` and `isEnabled`.
Read state again after entering required input to check that a control becomes enabled.
A disabled tap fails with the control's state in the message and screen report.

```swift
let save = try await user.sees(.button("Save"))
#expect(save.has(.button))
#expect(!save.isEnabled)
```

## Actions

Each act finds its element, does what VoiceOver offers, then waits for the screen to settle.

```swift
try await user.taps(.button("Save"))             // activates one control
try await user.types("Milk")                     // types into the field being edited
try await user.chooses("Archive", on: .text("Note"))  // a custom action
try await user.scrolls(.down)                    // or .up
try await user.goesBack()                        // as a two-finger scrub does
```

`goesBack()` passes only once what is read on screen changes. On the Mac, SwiftUI drops a focus set in `onAppear`, so set it one main-queue turn later.

## Waits

Every look and act polls until its condition holds or the deadline passes ([ADR 0003](architecture/adr/0003-condition-waits.md)). The default deadline is five seconds. Set one per user:

```swift
let user = User(screen, deadline: .seconds(3))
try await user.sees(.text("Loaded"))
try await user.doesNotSee(.text("Loading"))
```

`reads()` waits for the screen to settle, then returns every on-screen `Element` in VoiceOver's order.

```swift
let spoken = await user.reads().map(\.spoken)
#expect(spoken.contains("Milk"))
```

## Serialize the suite

Only one screen is open at a time, so Swift Testing suites that render must not run in parallel ([ADR 0005](architecture/adr/0005-one-window-per-process.md)). Nest them under one serialized parent. Mark every test and suite `@MainActor`.

```swift
@Suite(.serialized)
struct UITests {
    @MainActor @Suite struct Saving {
        @Test func savesMilk() async throws { /* render, act, close */ }
    }
}
```

## Read a failure

A failed look or act throws a `Failure`. Its text holds the message, the test line, and what VoiceOver read:

```
Expected to see text "Eggs", and nothing on screen matches (GroceryTests.swift:12)
On screen:
  "Groceries" (heading)
  "Milk"
  "Add" (button)
Drawn off screen:
  (nothing)
```

Fix the query or the screen. An empty read fails `close()` too, since it proved nothing.

## System menus

A tap on a control that opens system UI fails and says so. See [System menus](../README.md#system-menus) for what to do.
