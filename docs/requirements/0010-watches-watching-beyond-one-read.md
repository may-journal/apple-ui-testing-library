# 0010 Watching beyond one read

## Why

I check what a person notices over time: something that never shows, a screen that never freezes, and the share sheet opening.

## Measurement

watches that end at their set time or their first failure
-
watches

## Requirements

1. Fails a watch that sees an element
   1. GIVEN Developer has an element that appears later
      1. WHEN I watch that it never appears
         1. THEN the watch fails once it appears
2. Names the longest stall
   1. GIVEN Developer has a button that holds the main thread
      1. WHEN I tap it under a stall limit
         1. THEN the check fails naming the longest stall
3. Finds the share sheet
   1. GIVEN Developer has a button that opens the share sheet
      1. WHEN I tap it and look for the sheet
         1. THEN the look passes in process
