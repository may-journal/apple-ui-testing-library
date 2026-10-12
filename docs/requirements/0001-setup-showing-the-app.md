---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0001 Showing the app

## Why

I show my app's real root view at a person's text size and appearance. I read it the way a person using VoiceOver does.

## Measurement

tests that show a root view and read its accessibility tree
-
tests that show a root view

Source: #1

## Requirements

- 0001.3
    - Given a shown root view
        - When I read the screen
            - Then I get each element as VoiceOver says it, in order
- 0001.4
    - Given a sheet over the screen
        - When I read the screen
            - Then only the sheet is read
- 0001.5
    - Given a shown root view
        - When I show a second one
            - Then nothing from the first is read
- 0001.6
    - Given a root view
        - When I show it in a Mac app
            - Then I read what a person at a Mac sees
- 0001.7
    - Given a root view with hundreds of elements
        - When I read it ten times
            - Then all ten reads finish within 800 ms
- 0001.8
    - Given a root view that lays out differently on iPad
        - When I show it at phone width, then at iPad width
            - Then I read its phone layout, then its iPad layout
- 0001.9
    - Given a name and price that stack at accessibility text sizes
        - When I show them at one
            - Then I read the name and price stacked, both on screen
- 0001.10
    - Given a root view that follows the appearance
        - When I show it in dark, then in light
            - Then I read its dark look, then its light look
