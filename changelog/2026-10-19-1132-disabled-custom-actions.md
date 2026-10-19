---
relatedConfigurations: ['../.fitnessrc.json']
---

### 2026.10.19.1132

- Fix: choosing an advertised custom action on a disabled control fails before its handler runs and reports the disabled state
- Test: both hosted platforms check the failure and unchanged screen through a real SwiftUI fixture
- Docs: requirement 0006.5 records the disabled custom action behavior
