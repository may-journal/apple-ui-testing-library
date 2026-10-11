---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0008 Reading a system share

## Why

I follow a real share to a local destination and check the image and message it receives.

## Measurement

shares checked at their destination
-
shares tested

Source: #40

## Requirements

- 0008.1
    - Given an image and message
        - When I share through system UI
            - Then the local destination receives both
- 0008.2
    - Given a received card
        - When I read its image
            - Then it names only the chosen match
- 0008.3
    - Given the wrong image
        - When I check the delivery
            - Then the check fails despite the right message
- 0008.4
    - Given the wrong message
        - When I check the delivery
            - Then the check fails despite the right image
- 0008.5
    - Given an image with another match
        - When I check the delivery
            - Then the check names the unwanted match
- 0008.6
    - Given an absent control
        - When I wait for it
            - Then failure names my line and screen
- 0008.7
    - Given an open share sheet
        - When I cancel
            - Then the source screen returns
