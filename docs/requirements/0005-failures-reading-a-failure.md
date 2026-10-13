---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0005 Reading a failure

## Why

When a test fails, I read what a person would have seen then. So I fix the app or the test without rerunning.

## Measurement

failures that print what VoiceOver reads on screen
-
failures

Source: #1

## Requirements

- 0005.1
    - Given Developer has a look that fails
        - When I read the failure
            - Then it lists what VoiceOver reads on screen
- 0005.2
    - Given Developer has a label nothing tappable has
        - When I tap it
            - Then it fails saying nothing tappable has that label
- 0005.3
    - Given Developer has an element without the action I choose
        - When I choose it
            - Then it fails listing the actions offered
- 0005.4
    - Given Developer has an app exposing nothing to VoiceOver
        - When I look for something to be gone
            - Then the look fails saying the screen read empty
- 0005.5
    - Given Developer has any failure
        - When I open it in Xcode
            - Then it points at my test's line, not the library's
- 0005.6
    - Given Developer has a control absent from a system session
        - When I look for it
            - Then the failure names my line and lists the screen
