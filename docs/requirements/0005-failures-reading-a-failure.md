# 0005 Reading a failure

## Why

When a test fails, I read what a person would have seen then. So I fix the app or the test without rerunning.

## Measurement

failures that print what VoiceOver reads on screen
-
failures

## Requirements

1. Lists the screen
   1. GIVEN Developer has a look that fails
      1. WHEN I read the failure
         1. THEN it lists what VoiceOver reads on screen
2. Names a missing label
   1. GIVEN Developer has a label nothing tappable has
      1. WHEN I tap it
         1. THEN it fails saying nothing tappable has that label
3. Lists offered actions
   1. GIVEN Developer has an element without the action I choose
      1. WHEN I choose it
         1. THEN it fails listing the actions offered
4. Reports an empty screen
   1. GIVEN Developer has an app exposing nothing to VoiceOver
      1. WHEN I look for something to be gone
         1. THEN the look fails saying the screen read empty
5. Points at my line
   1. GIVEN Developer has any failure
      1. WHEN I open it in Xcode
         1. THEN it points at my test's line
         2. THEN not the library's
6. Names my line in a system session
   1. GIVEN Developer has a control absent from a system session
      1. WHEN I look for it
         1. THEN the failure names my line and lists the screen
