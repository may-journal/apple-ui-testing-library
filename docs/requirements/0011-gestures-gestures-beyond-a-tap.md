# 0011 Gestures beyond a tap

## Why

I double-tap, hold, swipe, drag, adjust, hover and pinch as a person does, in process and off screen. My test keeps no copy of these gestures.

## Measurement

gestures run in process through the platform's own entry points
-
gestures

## Requirements

1. Double taps
   1. GIVEN Developer has a view that counts double taps
      1. WHEN I double-tap it
         1. THEN it counts one double tap
         2. THEN not two taps
2. Long presses
   1. GIVEN Developer has a row with a context menu
      1. WHEN I long-press it
         1. THEN the menu's actions show
3. Swipes
   1. GIVEN Developer has a list row with swipe actions
      1. WHEN I swipe it left
         1. THEN its actions show
4. Drags to a target
   1. GIVEN Developer has an item and a drop target
      1. WHEN I drag the item onto the target
         1. THEN the target holds the item
5. Adjusts
   1. GIVEN Developer has a slider and a stepper
      1. WHEN I adjust each up and then down
         1. THEN each value steps up one
         2. THEN then back
6. Hovers
   1. GIVEN Developer has a view that shows a hover state
      1. WHEN I hover over it and then leave
         1. THEN the hover state shows
         2. THEN then clears
7. Stays off every display
   1. GIVEN Developer has a root view shown on a Mac
      1. WHEN I act on it
         1. THEN its window stays off every display
8. Pinches
   1. GIVEN Developer has a view that counts pinches by direction
      1. WHEN I pinch in on it and then pinch out
         1. THEN it counts one pinch in
         2. THEN then one pinch out
