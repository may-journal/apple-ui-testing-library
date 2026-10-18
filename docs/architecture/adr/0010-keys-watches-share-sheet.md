---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# 0010 — Keys, watches and the share sheet in process

## Context

Client tests kept private copies of Return, clearing a field, never-seen checks, stall timing and share-sheet checks. Plan #65 moves them into `User`.

## Decision

1. `presses(.enter)`, `presses(.end)` and `clears(_:)` follow user-event and run the field's own key commands. Each waits for a field, then settles.
2. `neverSees(_:for:)` watches for a set time and fails at the first match. Absence needs time to prove.
3. A `neverSees` that only read an empty screen fails, as `doesNotSee` does.
4. `staysResponsive(under:)` runs an action while a main run loop timer fires every 10 ms. The longest gap between fires is the stall.
5. `seesShareSheet()` waits for the share sheet's controller over the window. UIKit names it `UIActivityViewController`.
6. AppKit names no public type for its share popover, so the backend matches the controller's class name.

## Consequences

1. Client apps delete their copies once the release ships.
2. A stall includes the library's own reads during the action, as a person feels them.
3. `seesShareSheet()` proves the sheet opened, never what it holds. `UITestingLibrarySystem` still drives it ([ADR 0009](0009-system-sharing.md)).
4. A future AppKit rename of the share controller fails `seesShareSheet()` loudly, never silently.
