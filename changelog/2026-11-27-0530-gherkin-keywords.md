### 2026.11.27.0530

- Fix: each requirement step with a joined result or action is now separate numbered GIVEN, WHEN and THEN items.
- Fix: WHENs that give one result are grouped under one step, so no acceptance repeats a THEN.
- Test: cases for 0001, 0002, 0003, 0004, 0005, 0007, 0009, 0010, 0011 and 0012 assert each split result on its own.
