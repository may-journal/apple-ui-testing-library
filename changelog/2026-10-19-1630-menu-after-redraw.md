---
relatedConfigurations: ['../.fitnessrc.json']
---

### 2026.10.19.1630

- Fix: on the iOS app running on a Mac, tapping a SwiftUI `Menu` that just drew or redrew opens it
- Test: both hosted platforms choose from a menu, redraw the view around it, and open the menu again
- Docs: requirement 0003.7 covers tapping a menu after an item redrew the view
