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

`Screen.render` draws a root view in a window of the app's own. `close()` hides it and runs the canary check ([ADR 0004](architecture/adr/0004-automation-canary.md)). Pass `size: .pad` for an iPad layout. Rendering a second screen closes the first ([ADR 0005](architecture/adr/0005-one-window-per-process.md)).

```swift
let screen = try Screen.render { AppRoot() }
let user = User(screen)
// look and act here
try screen.close()
```

Pass a `Look` to draw the root at a text size or appearance a person chose. Each overrides the system's for that root only.

```swift
let screen = try Screen.render(look: Look(textSize: .accessibility3, appearance: .dark)) {
    AppRoot()
}
```

The root reads the text size and appearance from its environment, as on a device. A layout that changes for large text changes here too ([0001.9](requirements/0001-setup-showing-the-app.md)). A Mac draws text at one size whatever the setting, so text that would overflow on a phone still fits.

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

To check a required field enables saving, read the button after typing:

```swift
try await user.types("Milk")
let save = try await user.sees(.button("Save"))
#expect(save.isEnabled)
```

`goesBack()` passes only once what is read on screen changes. On the Mac, SwiftUI drops a focus set in `onAppear`, so set it one main-queue turn later.

## Keys

Keys follow [user-event](https://testing-library.com/docs/user-event/intro)'s `keyboard`, `tab`, `clear` and clipboard calls, through the field's own key commands and edit actions ([0009](requirements/0009-keys-pressing-keys-and-clearing-a-field.md), [ADR 0011](architecture/adr/0011-person-actions-in-process.md)). A shortcut that answers a key runs first. A Mac selects a one-line field's words as it gains focus, so press End before typing to add to them.

```swift
try await user.presses(.enter)               // keyboard("{Enter}"): submits a one-line field
try await user.presses(.end)                 // keyboard("{End}"): moves to the end
try await user.presses(.enter, with: [.command])  // a Cmd-Return shortcut
try await user.presses("3", with: [.command])     // keyboard("{Meta>}3{/Meta}"): a Cmd-3 shortcut
try await user.tabs()                        // tab(): the next field
try await user.tabs(backward: true)          // tab({shift: true}): the field before
try await user.clears(.role(.textField, "Note"))  // clear(element): edits it, deletes all
```

The named keys are `enter`, `end`, `home`, `escape`, `tab`, `delete` and the four arrows. Any other key is named by the character it types, such as `"3"`, and reaches the app's shortcuts with no field being edited. The modifiers are `command`, `shift`, `option` and `control`. With Shift, Home, End and the arrows select as they move.

The clipboard steps act in the field being edited. `pastes("Milk")` puts the text on the clipboard first, as `paste(text)` does. Closing the screen puts back what the clipboard held before.

```swift
try await user.selectsAll(in: .role(.textField, "Note"))
try await user.copies()                      // or cuts()
try await user.tabs()
try await user.pastes()
```

## Gestures

Gestures beyond a tap run in process, each through the platform's own entry point ([0011](requirements/0011-gestures-gestures-beyond-a-tap.md), [ADR 0011](architecture/adr/0011-person-actions-in-process.md)). `drags(_:by:speed:)` drags from the element's middle, right and down by the offset's points ([0012](requirements/0012-drags-drags-by-a-distance.md)). A slow drag comes to rest before letting go, and a flick lets go mid-move.

```swift
try await user.doubleTaps(.text("Photo"))    // dblClick(element): one double tap
try await user.longPresses(.text("Note"))    // opens its context menu
try await user.taps(.button("Delete"))       // runs a menu item
try await user.swipes(.left, .text("Milk"))  // shows a row's trailing swipe actions
try await user.drags(.text("Milk"), to: .text("Basket"))
try await user.adjusts(.up, .role(.adjustable, "Volume"))  // or .down
try await user.hovers(.text("Card"))         // hover(element)
try await user.unhovers(.text("Card"))       // unhover(element)
try await user.pinches(.in, .text("Map"))    // or .out: a trackpad's pinch
try await user.drags(.text("Photo"), by: CGVector(dx: -300, dy: 0), speed: .slow)  // or .flick
try await user.swipes(.left, .text("Photo")) // not a row: flicks it 100 points left
```

While a held menu is open, a read holds only its items, as for a tapped menu. A double tap, a hover, a pinch and a drag by a distance need a Mac's pointer or trackpad. On iOS they run where the app runs on a Mac. A Mac app's list shows swipe actions only for a trackpad's touches, so `swipes` fails there with a message saying so.

On a Mac the test window sits off every display, and the app never comes forward. A test never shows on screen or takes focus.

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

Two watches run for a set time instead ([0010](requirements/0010-watches-watching-beyond-one-read.md), [ADR 0010](architecture/adr/0010-keys-watches-share-sheet.md)). `neverSees(_:for:)` fails as soon as its query matches. `doesNotSee` returns once the match is gone. `staysResponsive(under:)` fails if the main thread stalls that long during its action, naming the longest stall.

```swift
try await user.neverSees(.button("Retry"), for: .seconds(2))
try await user.staysResponsive(under: .milliseconds(500)) {
    try await user.taps(.button("Share"))
}
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

A tap on a control that opens a menu, such as a SwiftUI `Menu` in the content or a navigation bar, opens it. While it is open, a read holds only its items, as VoiceOver reads them. Tap one to run it; the menu closes ([0003.7](requirements/0003-actions-doing-what-a-person-does.md)). `goesBack()` closes it without choosing one ([0003.8](requirements/0003-actions-doing-what-a-person-does.md)).

```swift
try await user.taps(.button("Add"))
try await user.sees(.button("Import"))
try await user.taps(.button("Import"))
```

`close()` closes a menu left open. A hosted tap on other system UI, such as a share sheet, still fails; drive it as [System UI](#system-ui) shows.

A hosted test can still check that the app opened the share sheet. `seesShareSheet()` waits for the sheet over the window, without reading or driving it ([0010.3](requirements/0010-watches-watching-beyond-one-read.md)):

```swift
try await user.taps(.button("Share"))
try await user.seesShareSheet()
```

## System UI

Hosted tests cannot drive a share sheet or Siri. Add the `UITestingLibrarySystem` product to a separate iOS UI-test target and use `SystemSession`. It accepts the same queries, reads `Element`s with their enabled state, and keeps your test's line in failures. Run these tests serially, and shut down each simulator you boot, even after failure.

### Share through the system

```swift
let session = SystemSession(bundleIdentifier: "org.example.App", timeout: 10)
session.launch(arguments: ["--test-share-destination"])
defer { session.close() }
try session.taps(.button("Share"))
let delivery = try session.receivesShare()
try delivery.check(message: "Alex's card", containing: ["Taylor"], excluding: ["Morgan"])
try session.dismissShare()
```

The app's test build must link the UIKit-only `UITestingLibraryShareDestination` product and add `LocalShareDestination()` to `UIActivityViewController`'s `applicationActivities`. Inject that destination at the share sheet seam; keep the app's real share action and rendering. Release builds omit the local destination.

UIKit delivers resolved items to the activity; the driver decodes its received PNG bytes and strings after a bounded wait. Vision reads those pixels, and `check` requires one image, an exact message, required phrases, and no forbidden phrases. Failures include recognized words; list every other match to prove absence ([ADR 0009](architecture/adr/0009-system-sharing.md)).

| Concern | Support |
| ------- | ------- |
| Roles | XCTest exposes the listed control roles and selected state; it does not expose heading traits. |
| Items | `UIImage`, image `Data`, and `String`; other types and installed destinations need their own receiver. |
| Receipt | `dismissShare()` finishes it. |
| Cancel | Pass the sheet's visible close query, such as `.button("Close")`, and verify the source screen returns. |
| Session | `close()` terminates only its app. |
| Simulator run | `make requirements-e2e SIMULATOR_ID=<udid>` boots your shut-down simulator, runs `SystemTests` in series, and shuts it down on failure too. |
| Runner inputs | Simulator UDID and Xcode project; refuses an already booted device. |
| Runner outputs | Build logs and test results in `.build/SystemDerivedData`. |
| Default run | `make requirements` stays native; consumers own their runner and device cleanup. |

### Ask Siri

Other platforms throw a setup error. Enable Siri, use the phrase's language, and launch the app to register its App Shortcuts. Siri may need a network connection and an account.

```swift
let session = SystemSession(bundleIdentifier: "org.example.app", timeout: 20)
session.launch()
defer { session.close() }
let answer = try session.askSiri("Who did I draw in Example", expecting: "Morgan drew Riley.")
try answer.excludes("Casey drew Morgan")
```

The service submits recognized speech, runs system phrase routing, and reads Siri's visible transcript without recording audio. Empty text throws a setup failure; unexpected nonempty text throws an indeterminate failure. That text may come from setup, network errors, routing, or the app; it proves no intent ran. Each failure carries the phrase, observed text and test line.

Run Siri tests on a prepared iOS device; activation itself can fail the test before a transcript is read. A response failure means forbidden text appeared after the expected answer was verified. `SiriTranscript.expecting` checks captured text only; see [ADR 0008](architecture/adr/0008-siri-system-requests.md).
