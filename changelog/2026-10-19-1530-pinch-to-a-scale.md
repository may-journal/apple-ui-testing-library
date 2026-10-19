---
relatedConfigurations: ['../.fitnessrc.json']
---

### 2026.10.19.1530

- Feat: `pinches(_:_:to:)` pinches to a chosen scale, which the view's magnify gesture reads on both Mac hosts
- Feat: `holdsPinch(_:_:to:)` holds a pinch partway, and its `releases()` lifts the fingers
- Fix: a pinch held as its screen closes is lifted, so the next screen's pinch is heard
- Docs: requirement 0013, ADR 0012, and the usage guide's gestures
