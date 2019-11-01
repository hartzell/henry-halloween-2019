# Notes for Henry's 2019 Halloween robot voice box

I built a voice effects box for Henry's robot costume.  Based on a
Teensy4 and audio shield.  It used a matrix keypad to play WAV files
and control volume, had an FFT based waterfall display running on its
TFT as eye candy, and used a voice effect based on "Dalek" effect from
the Teensy Forum.

I was in a hurry.  That's my excuse....

The code is a crude mashup of various examples.

- README.md -- This readme
- enclosure -- OpenSCAD models and STL files and gcode files for
  enclosure and battery holder.
- firmware -- arduino firmware for teensy4: controls matrix keypad,
  waterfall display for tft, and voice effects.
- pins.md -- document pins used
- sounds -- WAV files

## TODO

- borsboom's vocoder:
  - https://github.com/borsboom/vocoder
  - https://borsboom.io/vocoder/
