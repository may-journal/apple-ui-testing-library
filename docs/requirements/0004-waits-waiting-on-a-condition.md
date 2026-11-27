# 0004 Waiting on a condition

## Why

My tests wait only as long as the app needs, never a fixed time, so they stay fast and steady.

## Measurement

looks that end when their condition holds or at the deadline
-
looks

## Requirements

1. Passes when an element appears
   1. GIVEN Developer has an element that appears later
      1. WHEN I look for it
         1. THEN the look passes before the deadline
2. Fails at the deadline
   1. GIVEN Developer has an element that never appears
      1. WHEN I look for it
         1. THEN the look fails at the deadline I set
3. Passes when an element leaves
   1. GIVEN Developer has an element that leaves later
      1. WHEN I look for it to be gone
         1. THEN the look passes before the deadline
4. Reads the redrawn screen
   1. GIVEN Developer has a button that redraws the screen
      1. WHEN I tap it
         1. THEN my next look reads the redrawn screen
5. Stays fast
   1. GIVEN Developer has a long screen that each act redraws
      1. WHEN I run ten rounds of acting
         1. THEN all ten finish within 1.5 seconds
