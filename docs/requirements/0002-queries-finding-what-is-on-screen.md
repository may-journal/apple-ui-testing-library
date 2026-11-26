# 0002 Finding what is on screen

## Why

I find elements the way a person does: by role and label first, then by visible text. An identifier comes last, when nothing else tells them apart.

## Measurement

looks by role, label or text
-
looks

## Requirements

1. Finds a button by label
   1. GIVEN Developer has a button and plain text sharing a label
      1. WHEN I look for a button by that label
         1. THEN I get the button
2. Finds text
   1. GIVEN Developer has text on screen
      1. WHEN I look for it
         1. THEN I get the element saying it
3. Finds the selected element
   1. GIVEN Developer has one element VoiceOver calls selected
      1. WHEN I look for the selected one
         1. THEN I get it
4. Misses an element off screen
   1. GIVEN Developer has an element scrolled off screen
      1. WHEN I look for it
         1. THEN I find nothing
5. Finds by identifier
   1. GIVEN Developer has two elements sharing a label
      1. WHEN I look by identifier
         1. THEN I get the one with that identifier
