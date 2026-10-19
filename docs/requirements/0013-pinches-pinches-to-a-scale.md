---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0013 Pinches to a scale

## Why

I pinch to the scale I name, or hold a pinch partway and read the screen before letting go. A view that scales live under the fingers is tested headless.

## Measurement

pinches whose magnify gesture reads the scale asked for
-
pinches to a scale

Source: #95

## Requirements

- 0013.1
    - Given Developer has a view that reports the scale its pinch ends at
        - When I pinch out, then in, each to a chosen scale
            - Then it reports each scale
- 0013.2
    - Given Developer has a view that reports its pinch's scale as it changes
        - When I hold a pinch partway
            - Then it reports the held scale and no end
- 0013.3
    - Given Developer has a view that reports the scale its pinch ends at
        - When I hold a pinch partway, then release it
            - Then it reports the held scale as the end
- 0013.4
    - Given Developer has a view that reports its pinch
        - When I pinch in to a scale above 1
            - Then the step fails naming the range, and nothing pinches
- 0013.5
    - Given Developer left a pinch held as its screen closed
        - When I pinch on the next screen
            - Then that view reports the scale its pinch ends at
