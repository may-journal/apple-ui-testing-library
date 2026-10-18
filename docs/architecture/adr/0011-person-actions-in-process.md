---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# 0011 — Every person action, in process and off screen

## Context

Plan #70 adds user-event's other person actions. Plan #76 adds a pinch. VoiceOver offers no entry point for several. Hosted tests must never show on screen or take focus.

## Decision

1. A key reaches the window's shortcuts first, then the field. UIKit runs a matching key command up the responder chain.
2. Tab moves focus to the next field. The clipboard runs the responder chain's edit actions, and closing the screen restores it.
3. `adjusts` uses VoiceOver's increment and decrement. A UIKit stepper reads as one adjustable element.
4. A hold asks the view for the context menu it would open, through `menu(for:)` or its interaction, and draws nothing.
5. A double tap, a hover and a pinch send pointer or trackpad events, made in process, straight to the test's window.
6. A drag keeps SwiftUI's items in the hosting view. The target hears them through its own drop methods.
7. The Mac window sits off every display, counts as key and takes the first click. The app never activates.
8. A private name is a last resort, checked before use, so a rename fails the step loudly.
## Consequences

1. A Mac list shows swipe actions only for trackpad touches, so `swipes` fails clearly there. On iOS, UIKit's swipe controller opens the row.
2. An iPhone or iPad has no pointer or trackpad in process, so a double tap, hover or pinch fails clearly there.
3. A hover brings the iOS app's scene window onto a display, see-through. The next screen moves it off again.
4. A pinch brings that window on the same way, and moves it off once the pinch ends.
5. The private names are UIKit's swipe controller, a menu configuration's action provider, and the scene window's screen constraint.
6. Quartz names no gesture event's fields. A pinch sets them by number and places the event with `CGEventSetWindowLocation`.
7. Each magnify event must read back at its point, so a change in Quartz fails the pinch.
