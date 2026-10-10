---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# ADR 0004 — Private SPI turns automation on, and a canary guards it

Status: accepted

## Context

SwiftUI builds its accessibility tree only while an assistive technology asks. In a hosted test nothing asks, so the tree comes back empty. Xcode's UI tests turn automation on through `_AXSSetAutomationEnabled` in `libAccessibility`, which is private.

## Decision

1. `Automation` opens `/usr/lib/libAccessibility.dylib` with `dlopen` and calls `_AXSSetAutomationEnabled(1)` once per process.
2. A missing symbol is recorded, and the tree is read anyway.
3. `Canary` fails any test whose reads never found an element, saying automation is off.
4. The library ships in test targets only, so the app never links the private call.

## Consequences

- An OS update that empties the tree fails every test loudly on its first run.
- App Store review never sees the private symbol.
- A test that reads nothing at all also fails, since it proved nothing.
