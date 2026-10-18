---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0011 Gestures beyond a tap

## Why

I double-tap, hold, swipe, drag, adjust and hover as a person does, in process and off screen. My test keeps no copy of these gestures.

## Measurement

gestures run in process through the platform's own entry points
-
gestures

Source: #70

## Requirements

- 0011.1
    - Given Developer has a view that counts double taps
        - When I double-tap it
            - Then it counts one double tap, not two taps
- 0011.2
    - Given Developer has a row with a context menu
        - When I long-press it
            - Then the menu's actions show
- 0011.3
    - Given Developer has a list row with swipe actions
        - When I swipe it left
            - Then its actions show
- 0011.4
    - Given Developer has an item and a drop target
        - When I drag the item onto the target
            - Then the target holds the item
- 0011.5
    - Given Developer has a slider and a stepper
        - When I adjust each up, then down
            - Then each value steps up one, then back
- 0011.6
    - Given Developer has a view that shows a hover state
        - When I hover over it, then leave
            - Then the hover state shows, then clears
- 0011.7
    - Given Developer has a root view shown on a Mac
        - When I act on it
            - Then its window stays off every display
