---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# 0002 — Queries go by role and label first

## Context

Testing Library ranks queries by how a person finds things, and people cannot see an identifier. May Calendar's taps could land on static text that shared a button's label.

## Decision

1. `Query.role(_:_:)` matches a `Role`'s traits and the exact label. It comes first.
2. `Query.text(_:)` matches what VoiceOver says, label then value. It comes next.
3. `Query.identifier(_:)` matches `accessibilityIdentifier`. It is the last resort.
4. A tap needs an actionable element: a button, link, toggle, tab, adjustable element, or field. Typing needs a field being edited.
5. `get` fails when none or many match; `query` returns nil on none; `find` waits for exactly one.

## Consequences

1. A test fails when VoiceOver reads the wrong label, even if an identifier still matches.
2. Ambiguous screens fail loudly, which pushes apps toward distinct labels.
3. Docs and examples lead with role queries.
