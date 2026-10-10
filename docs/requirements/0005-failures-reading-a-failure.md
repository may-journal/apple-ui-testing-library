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
    - Given a look that fails
        - When I read the failure
            - Then it lists what VoiceOver reads on screen
- 0005.2
    - Given a label nothing tappable has
        - When I tap it
            - Then it fails saying nothing tappable has that label
- 0005.3
    - Given an element without the action I choose
        - When I choose it
            - Then it fails listing the actions offered
- 0005.4
    - Given an app exposing nothing to VoiceOver
        - When I look for something to be gone
            - Then the look fails saying the screen read empty
- 0005.5
    - Given any failure
        - When I open it in Xcode
            - Then it points at my test's line, not the library's
