---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# ADR 0005 — Tests run serialized, one key window per process

Status: accepted

## Context

UIKit has one key window per scene, and the tree a test reads is that window's. Swift Testing runs tests in parallel by default. May Calendar's harness also shares process-wide state, such as the time zone and `UserDefaults.standard`.

## Decision

1. Only one `Screen` is drawn at a time. Rendering a second while one is open fails the test.
2. Every API is `@MainActor`.
3. Swift Testing suites that use the library nest under one `.serialized` parent suite, or run with parallel testing off. XCTest runs serially.
4. Closing a screen hides its window and drops its root before the next test renders.

## Consequences

- Tests cannot share a window or leak one into the next.
- Parallel speed comes from runner clones, each its own process.
- Per-test state, such as stores and defaults, stays the consumer's job.
