---
relatedConfigurations: ['../../.fitnessrc.json']
---

# 0001 Showing the app

## Why

I show my app's real root view in a test and read it the way a person using VoiceOver does.

## Measurement

tests that show a root view and read its accessibility tree
-
tests that show a root view

Source: #1

## Requirements

- 0001.1
    - Given a SwiftUI root view
        - When I show it
            - Then I read what a person on a phone sees
- 0001.2
    - Given a root view that lays out differently on iPad
        - When I show it at iPad width
            - Then I read its iPad layout
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
            - Then all ten reads finish within half a second
