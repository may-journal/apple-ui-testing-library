# 0012 Drags by a distance

## Why

I drag any element by a distance and let go, slowly or as a flick, in process and off screen. A paging view or card stack is tested headless.

## Measurement

drags by a distance whose view hears the distance and the speed
-
drags by a distance

## Requirements

1. Reports a drag distance
   1. GIVEN Developer has a view that reports its drag distance
      1. WHEN I drop it after a slow drag by a set offset
         1. THEN it reports that offset
2. Reports a flick
   1. GIVEN Developer has a view that tells a flick from a slow drag
      1. WHEN I flick it a short way
         1. THEN it reports a flick
