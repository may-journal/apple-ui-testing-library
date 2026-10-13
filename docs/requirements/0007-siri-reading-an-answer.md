---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0007 Reading a Siri answer

## Why

I ask Siri through the system, so phrase routing and the displayed answer are part of my test.

## Measurement

Siri answers checked through the system
-
Siri answer tests

Source: #39

## Requirements

- 0007.1
    - Given Developer has three people and a caller
        - When I ask Siri for their match
            - Then only the caller's answer appears
- 0007.2
    - Given Developer has an app returning a wrong match
        - When I ask Siri for my match
            - Then failure shows phrase, answer and test line
- 0007.3
    - Given Developer has nonempty unverified Siri text
        - When I check the captured transcript
            - Then failure keeps its origin indeterminate
- 0007.4
    - Given Developer sees Siri dismiss its answer before timeout
        - When my expected answer differs
            - Then failure keeps the last observed answer
