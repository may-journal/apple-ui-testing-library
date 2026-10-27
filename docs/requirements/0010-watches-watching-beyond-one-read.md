# 0010 Watching beyond one read

## Why

I check what a person notices over time: something that never shows, a screen that never freezes, and the share sheet opening.

## Measurement

watches that end at their set time or their first failure
-
watches

## Requirements

- 0010.1
    - Given Developer has an element that appears later
        - When I watch that it never appears
            - Then the watch fails once it appears
- 0010.2
    - Given Developer has a button that holds the main thread
        - When I tap it under a stall limit
            - Then the check fails naming the longest stall
- 0010.3
    - Given Developer has a button that opens the share sheet
        - When I tap it and look for the sheet
            - Then the look passes in process
