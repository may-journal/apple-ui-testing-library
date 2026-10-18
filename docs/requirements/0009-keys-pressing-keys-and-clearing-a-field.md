---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0009 Pressing keys and clearing a field

## Why

I press Enter and End and clear a field as user-event does. My test keeps no copy of these keys.

## Measurement

keys pressed through the field's own key commands
-
keys pressed

Source: #65

## Requirements

- 0009.1
    - Given Developer has a one-line field being edited
        - When I press Enter
            - Then the field submits what it holds
- 0009.2
    - Given Developer has a field holding text
        - When I clear the field
            - Then the field reads empty
- 0009.3
    - Given Developer has a field with its words selected
        - When I press End and type
            - Then the typed text follows the words
