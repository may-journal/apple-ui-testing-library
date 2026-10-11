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
    - Given three people and a caller
        - When I ask Siri for their match
            - Then only the caller's answer appears
- 0007.2
    - Given a working Siri request
        - When I expect a wrong answer
            - Then failure shows phrase, answer and test line
