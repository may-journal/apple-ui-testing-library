---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# 0005 — Tests run serialized, one key window per process

## Context

A test reads its scene's one key window, but Swift Testing runs in parallel by default. An app's own harness may also share process-wide state.

## Decision

1. Only one `Screen` is drawn at a time. Rendering a second closes the first, so nothing from it is read (requirement 0001.5).
2. Every API is `@MainActor`.
3. Swift Testing suites that use the library nest under one `.serialized` parent suite, or run with parallel testing off. XCTest runs serially.
4. Closing a screen hides its window and drops its root before the next test renders.

## Consequences

1. Tests cannot share a window or leak one into the next.
2. Parallel speed comes from runner clones, each its own process.
3. Per-test state, such as stores and defaults, stays the consumer's job.
