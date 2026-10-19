---
relatedConfigurations: ['../.fitnessrc.json']
---

### 2026.10.18.1901

- Feat: `drags(query, by: offset, speed: .slow)` drags any element by a distance and lets go
- Feat: `.flick` lets go mid-move, so a view's drag gesture hears a flick
- Feat: `swipes` flicks any element that isn't a list row, such as a paging view
- Feat: a drag by a distance runs in process on both Mac hosts, and the test window stays off screen
- Docs: requirement 0012, ADR 0011, and the usage guide's gestures
