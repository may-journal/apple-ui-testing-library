---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# ADR 0002 — Queries go by role and label first

Status: accepted

## Context

Testing Library ranks queries by how a person finds things: role and name, then text, then test IDs. People cannot see or hear an `accessibilityIdentifier`. May Calendar's harness checked a trait only in `sees(button:)`, so a tap could land on static text that shared a label.

## Decision

1. `Query.role(_:_:)` matches a `Role`'s traits and the exact label. It comes first.
2. `Query.text(_:)` matches what VoiceOver says, label then value. It comes next.
3. `Query.identifier(_:)` matches `accessibilityIdentifier`. It is the last resort.
4. A tap needs an actionable element: a button, link, toggle, tab, adjustable element, or field. Typing needs a field being edited.
5. `get` fails when none or many match; `query` returns nil on none; `find` waits for exactly one.

## Consequences

- A test fails when VoiceOver reads the wrong label, even if an identifier still matches.
- Ambiguous screens fail loudly, which pushes apps toward distinct labels.
- Docs and examples lead with role queries.
