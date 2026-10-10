---
relatedConfigurations: ['../../.fitnessrc.json']
---

# Architecture

Product and system design for apple-ui-testing-library. The C4 docs below are the planned design; no Swift source has landed yet.

## Principles

1. Tests resemble the way the app is used. They read what VoiceOver reads and act through what VoiceOver offers.
1. The app under test runs in-process, built from its real root view ([ADR 0001](adr/0001-in-process-accessibility-tree.md)).
1. Queries follow one priority: role and label, then visible text, then identifier ([ADR 0002](adr/0002-query-priority.md)).
1. Every wait is a condition with a deadline, and nothing animates ([ADR 0003](adr/0003-condition-waits.md)).
1. A test that reads an empty tree fails loudly ([ADR 0004](adr/0004-automation-canary.md)).

## Start here

[00-kickoff-questions.md](00-kickoff-questions.md) — what the library is and who it serves.

## C4 docs

| Order | File                                         | Status   |
| ----- | -------------------------------------------- | -------- |
| 01    | [01-system-context.md](01-system-context.md) | planned  |
| 02    | [02-containers.md](02-containers.md)         | planned  |
| 03    | [03-components.md](03-components.md)         | planned  |
| 04    | [04-code.md](04-code.md)                     | planned  |
| 05    | [05-user-journey.md](05-user-journey.md)     | planned  |

## Decision records

Architecture decision records live in [adr/](adr/). A record is rewritten in place when its decision changes.

| ADR | Decision |
| --- | --- |
| [0001](adr/0001-in-process-accessibility-tree.md) | Tests read the accessibility tree in-process; XCUITest is left out. |
| [0002](adr/0002-query-priority.md) | Queries go by role and label first, visible text next, identifier last. |
| [0003](adr/0003-condition-waits.md) | Waits poll a condition up to a deadline; nothing sleeps and nothing animates. |
| [0004](adr/0004-automation-canary.md) | Private SPI turns automation on, and a canary fails any test that read nothing. |
| [0005](adr/0005-one-window-per-process.md) | Tests run serialized, one key window per process. |
