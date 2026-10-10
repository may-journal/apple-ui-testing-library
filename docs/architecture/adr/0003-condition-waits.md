---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# ADR 0003 — Waits poll a condition up to a deadline

Status: accepted

## Context

May Calendar's harness slept after every action and scaled real time by a process-wide pace. Under load, waits raced the poll and transitions left elements mid-flight. Apple's own advice is a condition with a deadline, as `XCTWaiter` does.

## Decision

1. Every look and act waits on a condition, up to a deadline of five seconds by default.
2. After each act, `Wait` polls until two reads of the tree match.
3. No API sleeps for a fixed time.
4. `Screen` turns animations off, with `UIView.setAnimationsEnabled(false)` and a root transaction that disables them.

## Consequences

- A fast machine finishes at once; a slow one takes longer and still passes.
- A deadline that passes fails with the screen report.
- Each app owns its own clock; the library ships none.
