---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0003 Doing what a person does

## Why

I tap controls and menu items, choose, type, scroll and go back through what VoiceOver offers. My test uses only what the app gives everyone.

## Measurement

actions done through an accessibility action
-
actions

Source: #1

## Requirements

- 0003.1
    - Given a button on screen
        - When I tap its label
            - Then its action runs
- 0003.2
    - Given an element with custom actions
        - When I choose one by name
            - Then that action runs
- 0003.3
    - Given a field being edited
        - When I type text
            - Then the text lands in that field
- 0003.4
    - Given content longer than the screen
        - When I scroll
            - Then what was below comes on screen
- 0003.5
    - Given a pushed view
        - When I go back
            - Then the view behind returns
- 0003.6
    - Given an alert or a confirmation dialog over the screen
        - When I read it and tap one of its buttons
            - Then I hear its title, and that button's action runs
- 0003.7
    - Given a control that opens a menu
        - When I tap it, read the menu, and tap an item
            - Then I hear each item, and that item's action runs
- 0003.8
    - Given a control's menu is open
        - When I go back
            - Then the menu closes without running an item
