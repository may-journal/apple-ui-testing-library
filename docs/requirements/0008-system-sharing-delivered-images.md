---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0008 Reading a system share

## Why

I follow a real share to a local destination and check the image and message it receives. A failed check shows my line and the evidence received.

## Measurement

shares checked at their destination
-
shares tested

Source: #40

## Requirements

- 0008.1
    - Given Developer has an image and message
        - When I share through system UI
            - Then the local destination receives both
- 0008.2
    - Given Developer has a received card
        - When I read its image
            - Then it names only the chosen match
- 0008.3
    - Given Developer has the wrong image
        - When I check the delivery
            - Then the check fails despite the right message
- 0008.4
    - Given Developer has the wrong message
        - When I check the delivery
            - Then the check fails despite the right image
- 0008.5
    - Given Developer has an image with another match
        - When I check the delivery
            - Then the check names the unwanted match
- 0008.7
    - Given Developer has an open share sheet
        - When I cancel
            - Then the source screen returns
- 0008.8
    - Given Developer has a share button below the screen
        - When I scroll down
            - Then I can tap it
- 0008.9
    - Given Developer has a delivery with a missing or unreadable image
        - When I check the delivery
            - Then failure shows my line and received message
