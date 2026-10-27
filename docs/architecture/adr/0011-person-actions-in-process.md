# 0011 — Every person action, in process and off screen

## Context

Plan #70 adds user-event's other person actions. Plans #76 and #83 add a pinch, any key's shortcut and a drag by a distance. VoiceOver offers no entry point for several. Hosted tests must never show on screen or take focus.

## Decision

1. A key reaches the window's shortcuts, then the app's menu commands, then the field. UIKit runs the key's command up its responder chain.
2. Tab moves focus to the next field. The clipboard runs the responder chain's edit actions, and closing the screen restores it.
3. `adjusts` uses VoiceOver's increment and decrement. A UIKit stepper reads as one adjustable element.
4. A hold asks the view for the context menu it would open, through `menu(for:)` or its interaction, and draws nothing.
5. A double tap, hover, pinch and drag by a distance send pointer or trackpad events, made in process, to the test's window.
6. A drag keeps SwiftUI's items in the hosting view. The target hears them through its own drop methods.
7. The Mac window sits off every display, counts as key and takes the first click. The app never activates.
8. A private name is a last resort, checked before use, so a rename fails the step loudly.

## Consequences

1. `swipes` flicks anything but a list row. A Mac list shows swipe actions only for trackpad touches, so swiping one fails there.
2. An iPhone or iPad sends no pointer or trackpad events in process, so a double tap, hover, pinch or distance drag fails.
3. A hover brings the iOS app's scene window onto a display, see-through. The next screen moves it off again.
4. A pinch brings that window on the same way, waits until the window server places it, then moves it off after.
5. The private names are UIKit's swipe controller, a menu configuration's action provider, and the scene window's screen constraint.
6. Quartz names no gesture event's fields. A pinch sets them by number and places the event with `CGEventSetWindowLocation`.
7. Each magnify event must read back at its point, so a change in Quartz fails the pinch.
8. The iOS app's never-key window keeps a lone press, so drags go to its input view, which stamps touches on arrival.
