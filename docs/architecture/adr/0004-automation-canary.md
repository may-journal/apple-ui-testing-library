---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# 0004 — Private SPI turns automation on, and a canary guards it

## Context

SwiftUI builds its accessibility tree only while assistive technology asks, so a hosted test reads nothing. Xcode turns automation on through a private call.

## Decision

1. `Automation` opens `/usr/lib/libAccessibility.dylib` with `dlopen` and calls `_AXSSetAutomationEnabled(1)` once per process.
2. A missing symbol is recorded, and the tree is read anyway.
3. `Canary` fails any test whose reads never found an element, saying automation is off.
4. The library ships in test targets only, so the app never links the private call.

## Consequences

1. An OS update that empties the tree fails every test loudly on its first run.
2. App Store review never sees the private symbol.
3. A test that reads nothing at all also fails, since it proved nothing.
