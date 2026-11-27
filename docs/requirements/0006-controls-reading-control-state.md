# 0006 Reading control state

## Why

I can check whether a control is disabled through the library, and a disabled control cannot act.

## Measurement

control state checks through the public library
-
control state checks

## Requirements

1. Reads a disabled control
   1. GIVEN Developer has a control disabled until required input is supplied
      1. WHEN I read it by role with its label
         1. THEN its public element reports disabled
2. Refuses a disabled tap
   1. GIVEN Developer has a disabled control
      1. WHEN I tap it
         1. THEN the action does not run
         2. THEN the failure shows its disabled state
3. Enables after input
   1. GIVEN Developer has a control disabled until required input is supplied
      1. WHEN I supply the input
         1. THEN its public element reports enabled
         2. THEN I can activate it
4. Reads a disabled share button
   1. GIVEN Developer has a disabled share button in a system session
      1. WHEN I read it
         1. THEN its state reports disabled
      2. WHEN I try to tap it
         1. THEN its failure reports disabled
         2. THEN no share opens
5. Refuses a disabled custom action
   1. GIVEN Developer has a disabled control that offers a custom action
      1. WHEN I choose that action
         1. THEN the action does not run
         2. THEN the failure shows its disabled state
