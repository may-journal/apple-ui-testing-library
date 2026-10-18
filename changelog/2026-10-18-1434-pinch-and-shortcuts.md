---
relatedConfigurations: ['../.fitnessrc.json']
---

### 2026.10.18.1434

- Feat: `pinches(.in, query)` and `pinches(.out, query)` pinch an element as two fingers on a trackpad do
- Feat: a pinch runs in process on both Mac hosts, and the test window stays off screen
- Feat: `presses` takes any character key, such as `presses("3", with: [.command])`
- Feat: a press with no field being edited reaches the app's shortcuts and menu commands
- Docs: requirements 0009.8 and 0011.8, ADR 0011, and the usage guide's keys and gestures
