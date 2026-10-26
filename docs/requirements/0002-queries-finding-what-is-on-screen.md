---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0002 Finding what is on screen

## Why

I find elements the way a person does: by role and label first, then by visible text. An identifier comes last, when nothing else tells them apart.

## Measurement

looks by role, label or text
-
looks

## Requirements

- 0002.1
    - Given Developer has a button and plain text sharing a label
        - When I look for a button by that label
            - Then I get the button
- 0002.2
    - Given Developer has text on screen
        - When I look for it
            - Then I get the element saying it
- 0002.3
    - Given Developer has one element VoiceOver calls selected
        - When I look for the selected one
            - Then I get it
- 0002.4
    - Given Developer has an element scrolled off screen
        - When I look for it
            - Then I find nothing
- 0002.5
    - Given Developer has two elements sharing a label
        - When I look by identifier
            - Then I get the one with that identifier
