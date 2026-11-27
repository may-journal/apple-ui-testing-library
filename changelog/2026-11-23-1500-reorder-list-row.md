### 2026.11.23.1500

> A drag from one reorder handle onto another moves the row of an iOS list in edit mode.

- Fix: a drag tells its source that it began and gives the drop its own session, so a list takes the reorder
- Test: requirement 0013.1 reorders a three-row list on the iOS host
- Docs: the usage guide shows a reorder by handle
- Refactor: a drop session takes its drag when made, and requirement 0013 has its own test file
