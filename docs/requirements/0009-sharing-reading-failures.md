---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0009 Reading share failures

## Why

I need a share failure to show my test line and the received evidence, even when no image can be read.

## Measurement

unreadable shares with located failures
-
unreadable shares checked

Source: #40

## Requirements

- 0009.1
    - Given a delivery without an image
        - When I check it
            - Then failure shows my line and received message
- 0009.2
    - Given unreadable image bytes
        - When I check the delivery
            - Then failure shows my line and received message
