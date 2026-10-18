---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0009 Pressing keys and clearing a field

## Why

I press any key with modifiers, run the app's shortcuts, tab between fields, clear a field and use the clipboard as user-event does. My test keeps no copy of these steps.

## Measurement

keys and clipboard steps run through the field's own key commands and edit actions
-
keys and clipboard steps

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
- 0009.4
    - Given Developer has a field in a view with a Cmd+Return shortcut
        - When I press Enter with Command
            - Then the shortcut runs, and the field holds no new line
- 0009.5
    - Given Developer has a form of two fields, the first being edited
        - When I tab, then tab backward
            - Then focus moves to the second field, then back
- 0009.6
    - Given Developer has a field holding text
        - When I select all, copy, and paste into an empty field
            - Then both fields hold the text
- 0009.7
    - Given Developer has a field holding text
        - When I select all and cut
            - Then the field reads empty, and pasting brings the text back
- 0009.8
    - Given Developer has a view with a Cmd+3 shortcut and no field focused
        - When I press 3 with Command
            - Then the shortcut runs
