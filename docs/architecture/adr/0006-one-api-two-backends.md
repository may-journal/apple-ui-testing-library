---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# 0006 — One API over two backends, UIKit and AppKit

## Context

The owner chose iOS and macOS from the start. UIKit and AppKit expose the tree through different types. A Mac app's tests should read its real AppKit tree, not an iPad layout.

## Decision

1. The public API is one set of types, with no platform in its names.
2. On iOS the backend draws in a `UIWindow` through `UIHostingController` and reads `accessibilityElements`, as [ADR 0001](0001-in-process-accessibility-tree.md) states.
3. On macOS the backend draws in an `NSWindow` through `NSHostingView` and reads `accessibilityChildren()`.
4. SwiftUI's Mac nodes answer `NSAccessibility` messages without adopting the protocol, so the backend sends them through dynamic lookup.
5. Each backend lives in `Tree/` and `Screen/` behind `#if canImport(UIKit)` and `#if canImport(AppKit)`; nothing else branches on platform.
6. A look or act fails by throwing a `Failure` carrying the test's own file and line.
7. The repo keeps one host app and one hosted test bundle per platform, and `make requirements` runs both.
8. The iOS bundle proves every acceptance; the Mac bundle proves the Mac one.

## Consequences

1. A test written against one platform reads the same on the other; only the host app differs.
2. Each backend is proven against its own platform's tree, so a Mac-only accessibility gap fails on the Mac.
3. Two backends mean two places to fix when an OS release changes its tree.
4. The iOS host still runs on a Mac as Designed for iPad, but that proves the UIKit backend only.
