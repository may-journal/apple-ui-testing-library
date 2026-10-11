---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0004 Waiting on a condition

## Why

My tests wait only as long as the app needs, never a fixed time, so they stay fast and steady.

## Measurement

looks that end when their condition holds or at the deadline
-
looks

Source: #1

## Requirements

- 0004.1
    - Given an element that appears later
        - When I look for it
            - Then the look passes before the deadline
- 0004.2
    - Given an element that never appears
        - When I look for it
            - Then the look fails at the deadline I set
- 0004.3
    - Given an element that leaves later
        - When I look for it to be gone
            - Then the look passes before the deadline
- 0004.4
    - Given a button that redraws the screen
        - When I tap it
            - Then my next look reads the redrawn screen
- 0004.5
    - Given a long screen that each act redraws
        - When I tap, choose and look ten times
            - Then all ten finish within a second
