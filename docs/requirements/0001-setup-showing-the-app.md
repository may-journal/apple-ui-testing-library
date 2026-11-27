# 0001 Showing the app

## Why

I show my app's real root view at a person's text size and appearance. I read it the way a person using VoiceOver does.

## Measurement

tests that show a root view and read its accessibility tree

-

tests that show a root view

## Requirements

1. Removed in 2026.11.26.1140: the original acceptance was dropped before the numbered form
2. Removed in 2026.11.26.1140: the original acceptance was dropped before the numbered form
3. Reads each element
   1. GIVEN Developer has shown a root view
      1. WHEN I read the screen
         1. THEN I get each element as VoiceOver says it
         2. THEN in order
4. Reads only a sheet
   1. GIVEN Developer has a sheet over the screen
      1. WHEN I read the screen
         1. THEN only the sheet is read
5. Drops the first root view
   1. GIVEN Developer has shown a root view
      1. WHEN I show a second one
         1. THEN nothing from the first is read
6. Reads a Mac app
   1. GIVEN Developer has a root view
      1. WHEN I show it in a Mac app
         1. THEN I read what a person at a Mac sees
7. Reads fast
   1. GIVEN Developer has a root view with hundreds of elements
      1. WHEN I read it ten times
         1. THEN all ten reads finish within 800 ms
8. Reads phone then iPad layouts
   1. GIVEN Developer has a root view that lays out differently on iPad
      1. WHEN I show it at each width
         1. THEN I read its phone layout
         2. THEN I read its iPad layout
9. Reads stacked text
   1. GIVEN Developer has a name
   2. GIVEN a price
   3. GIVEN both stack at accessibility text sizes
      1. WHEN I show them at one
         1. THEN I read the name stacked
         2. THEN I read the price stacked
         3. THEN both on screen
10. Reads dark then light
    1. GIVEN Developer has a root view that follows the appearance
       1. WHEN I show it in each appearance
          1. THEN I read its dark look
          2. THEN I read its light look
