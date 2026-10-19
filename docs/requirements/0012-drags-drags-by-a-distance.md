---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0012 Drags by a distance

## Why

I drag any element by a distance and let go, slowly or as a flick, in process and off screen. A paging view or card stack is tested headless.

## Measurement

drags by a distance whose view hears the distance and the speed
-
drags by a distance

Source: #83

## Requirements

- 0012.1
    - Given Developer has a view that reports its drag distance
        - When I drag it slowly by a set offset and let go
            - Then it reports that offset
- 0012.2
    - Given Developer has a view that tells a flick from a slow drag
        - When I flick it a short way
            - Then it reports a flick
