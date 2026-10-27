### 2026.10.19.1630

- Fix: on the iOS app running on a Mac, a SwiftUI `Menu` that just redrew opens when tapped
- Fix: each read lays out the window first
- Fix: only a menu the library cancelled holds an act while it closes
- Test: both hosted platforms choose from a menu, redraw the view around it, and open the menu again
- Docs: requirement 0003.7 covers tapping a menu after an item redrew the view
