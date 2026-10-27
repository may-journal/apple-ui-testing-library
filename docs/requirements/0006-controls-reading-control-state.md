# 0006 Reading control state

## Why

I can check whether a control is disabled through the library, and a disabled control cannot act.

## Measurement

control state checks through the public library
-
control state checks

## Requirements

- 0006.1
    - Given Developer has a control disabled until required input is supplied
        - When I read it by role and label
            - Then its public element reports disabled
- 0006.2
    - Given Developer has a disabled control
        - When I tap it
            - Then the action does not run and the failure shows its disabled state
- 0006.3
    - Given Developer has a control disabled until required input is supplied
        - When I supply the input
            - Then its public element reports enabled and I can activate it
- 0006.4
    - Given Developer has a disabled share button in a system session
        - When I read it and try to tap it
            - Then its state and failure report say disabled and no share opens
- 0006.5
    - Given Developer has a disabled control that offers a custom action
        - When I choose that action
            - Then the action does not run and the failure shows its disabled state
