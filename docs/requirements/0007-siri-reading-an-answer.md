# 0007 Reading a Siri answer

## Why

I ask Siri through the system, so phrase routing and the displayed answer are part of my test.

## Measurement

Siri answers checked through the system
-
Siri answer tests

## Requirements

1. Answers only the caller
   1. GIVEN Developer has three people
   2. GIVEN a caller
      1. WHEN I ask Siri for their match
         1. THEN only the caller's answer appears
2. Shows a wrong match
   1. GIVEN Developer has an app returning a wrong match
      1. WHEN I ask Siri for my match
         1. THEN failure shows phrase
         2. THEN failure shows the answer
         3. THEN failure shows my test line
3. Keeps the origin indeterminate
   1. GIVEN Developer has nonempty unverified Siri text
      1. WHEN I check the captured transcript
         1. THEN failure keeps its origin indeterminate
4. Keeps the last answer
   1. GIVEN Developer sees Siri dismiss its answer before timeout
      1. WHEN my expected answer differs
         1. THEN failure keeps the last observed answer
