# 0003 Doing what a person does

## Why

I tap controls and menu items, choose, type, scroll and go back through what VoiceOver offers. My test uses only what the app gives everyone.

## Measurement

actions done through an accessibility action
-
actions

## Requirements

1. Taps a button
   1. GIVEN Developer has a button on screen
      1. WHEN I tap its label
         1. THEN its action runs
2. Chooses a custom action
   1. GIVEN Developer has an element with custom actions
      1. WHEN I choose one by name
         1. THEN that action runs
3. Types into a field
   1. GIVEN Developer has a field being edited
      1. WHEN I type text
         1. THEN the text lands in that field
4. Scrolls
   1. GIVEN Developer has content longer than the screen
      1. WHEN I scroll
         1. THEN what was below comes on screen
5. Goes back
   1. GIVEN Developer has pushed a view
      1. WHEN I go back
         1. THEN the view behind returns
6. Answers an alert
   1. GIVEN Developer has an alert or a confirmation dialog over the screen
      1. WHEN I read it
         1. THEN I hear its title
      2. WHEN I tap one of its buttons
         1. THEN that button's action runs
7. Taps a menu item
   1. GIVEN Developer has a control or a navigation bar button that opens a menu
   2. GIVEN an item that redraws the view
      1. WHEN I open the menu
         1. THEN I hear each item
      2. WHEN I tap an item
         1. THEN that item's action runs
8. Closes a menu
   1. GIVEN Developer has a control's menu open
      1. WHEN I go back
         1. THEN the menu closes without running an item
