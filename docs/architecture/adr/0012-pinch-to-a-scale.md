---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# 0012 — Pinch to a scale, whole or held

## Context

Plan #95 lets a pinch end at a chosen scale, or hold partway. UIKit on a Mac makes a pinch in's scale from the trackpad's magnification by an undocumented curve.

## Decision

1. A pinch moves in five even steps of scale, then ends, or holds until `releases()`.
2. A Mac app's magnify gesture sums the events, so its steps are fixed.
3. The iOS app's pinch puts a `UIPinchGestureRecognizer` on the test's window. It recognizes alongside every gesture and holds back no touch.
4. Each step aims by the scale that recognizer last read, and a few more correct the end to within a ten-thousandth.
5. Closing a screen lifts a held pinch with its ended event.

## Consequences

1. The app's gesture reads the scale the test names on both hosts.
2. Only one pinch is held at a time; another pinch fails until it is released.
3. A pinch left held ends with its screen, so the next screen's pinch begins anew.
4. A pinch in may move its fingers back a little as it corrects.
