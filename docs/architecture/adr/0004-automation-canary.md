# 0004 — Private SPI turns automation on, and a canary guards it

## Context

SwiftUI builds its accessibility tree only while assistive technology asks, so a hosted test reads nothing. Xcode and VoiceOver each turn it on through a call apps never make.

## Decision

1. On iOS, `Automation` opens `/usr/lib/libAccessibility.dylib` with `dlopen` and calls `_AXSSetAutomationEnabled(1)` once per process.
2. On macOS, it sets `AXEnhancedUserInterface` on the app, as VoiceOver does when it starts reading one.
3. A missing symbol is recorded, and the tree is read anyway.
4. `Canary` fails any screen closed before a read found an element, and a look for something gone that only read empty.
5. The library ships in test targets only, so the app never links the private call.

## Consequences

1. An OS update that empties the tree fails every test loudly on its first run.
2. App Store review never sees the private symbol.
3. A test that reads nothing at all also fails, since it proved nothing.
