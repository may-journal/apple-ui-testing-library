# 0008 Reading a system share

## Why

I follow a real share to a local destination and check the image and message it receives. A failed check shows my line and the evidence received.

## Measurement

shares checked at their destination
-
shares tested

## Requirements

1. Delivers image and message
   1. GIVEN Developer has an image
   2. GIVEN a message
      1. WHEN I share through system UI
         1. THEN the local destination receives both
2. Names the chosen match
   1. GIVEN Developer has a received card
      1. WHEN I read its image
         1. THEN it names only the chosen match
3. Fails a wrong image
   1. GIVEN Developer has the wrong image
      1. WHEN I check the delivery
         1. THEN the check fails despite the right message
4. Fails a wrong message
   1. GIVEN Developer has the wrong message
      1. WHEN I check the delivery
         1. THEN the check fails despite the right image
5. Names an unwanted match
   1. GIVEN Developer has an image with another match
      1. WHEN I check the delivery
         1. THEN the check names the unwanted match
6. Removed in 2026.11.26.1140: the original acceptance was dropped before the numbered form
7. Cancels a share
   1. GIVEN Developer has an open share sheet
      1. WHEN I cancel
         1. THEN the source screen returns
8. Scrolls to a share button
   1. GIVEN Developer has a share button below the screen
      1. WHEN I scroll down
         1. THEN I can tap it
9. Shows a missing image
   1. GIVEN Developer has a delivery with a missing or unreadable image
      1. WHEN I check the delivery
         1. THEN failure shows my line
         2. THEN failure shows the received message
