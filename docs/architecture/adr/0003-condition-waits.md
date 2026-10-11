---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# 0003 — Waits poll a condition up to a deadline

## Context

An existing harness slept after every action, so under load its waits raced and transitions left elements mid-flight. Apple advises a condition with a deadline.

## Decision

1. Every look and act waits on a condition, up to a deadline of five seconds by default.
2. After each act, `Wait` lets the main run loop go idle twice, then reads the tree once.
3. No API sleeps for a fixed time.
4. `Screen` turns animations off, with `UIView.setAnimationsEnabled(false)` and a root transaction that disables them.

## Consequences

1. A fast machine finishes at once; a slow one takes longer and still passes.
2. A deadline that passes fails with the screen report.
3. Each app owns its own clock; the library ships none.
