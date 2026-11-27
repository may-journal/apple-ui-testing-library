# 0009 Pressing keys and clearing a field

## Why

I press any key with modifiers, run the app's shortcuts, tab between fields, clear a field and use the clipboard as user-event does. My test keeps no copy of these steps.

## Measurement

keys and clipboard steps run through the field's own key commands and edit actions
-
keys and clipboard steps

## Requirements

1. Submits on Enter
   1. GIVEN Developer has a one-line field being edited
      1. WHEN I press Enter
         1. THEN the field submits what it holds
2. Clears a field
   1. GIVEN Developer has a field holding text
      1. WHEN I clear the field
         1. THEN the field reads empty
3. Types after End
   1. GIVEN Developer has a field with its words selected
   2. GIVEN End pressed
      1. WHEN I type
         1. THEN the typed text follows the words
4. Runs a shortcut
   1. GIVEN Developer has a field in a view with a Cmd+Return shortcut
      1. WHEN I press Enter with Command
         1. THEN the shortcut runs
         2. THEN the field holds no new line
5. Tabs between fields
   1. GIVEN Developer has a form of two fields
   2. GIVEN the first being edited
      1. WHEN I tab
         1. THEN focus moves to the second field
      2. WHEN I step backward with Shift
         1. THEN focus moves back to the first field
6. Copies and pastes
   1. GIVEN Developer has a field holding text
   2. GIVEN all of it selected
   3. GIVEN an empty field
      1. WHEN I copy-paste it into the empty field
         1. THEN both fields hold the text
7. Cuts
   1. GIVEN Developer has a field holding text
   2. GIVEN all of it selected
      1. WHEN I cut
         1. THEN the field reads empty
         2. THEN pasting brings the text back
8. Runs a shortcut with no field
   1. GIVEN Developer has a view with a Cmd+3 shortcut
   2. GIVEN no field focused
      1. WHEN I press 3 with Command
         1. THEN the shortcut runs
