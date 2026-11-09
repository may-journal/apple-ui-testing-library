### 2026.11.09.1600

> The components view's legend keys only the element kinds the diagram uses.

- Docs: the components legend drops its Person sample, since the diagram shows no person.
- Docs: the unused Person style leaves the legend with it.
- Fix: the `doc-template` check passes the coming rule that a legend shows exactly the kinds its diagram uses.
