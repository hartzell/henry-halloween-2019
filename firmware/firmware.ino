// Firmware for Henry's Robot Voicebox
// George Hartzell 20191028
// See copyright notices and credits at bottom of file.

#include <Audio.h>
#include <ILI9341_t3.h>
#include <Keypad.h>
#include <SD.h>
#include <SPI.h>
#include <SerialFlash.h>
#include <Wire.h>

#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>

// GUItool: begin automatically generated code
AudioInputI2S            i2s1;           //xy=249.4444465637207,138.33333015441895
AudioSynthWaveformSine   sine1;          //xy=396,141
AudioMixer4              mixer1;         //xy=400,71
AudioMixer4              mixer2;         //xy=401,232
AudioEffectMultiply      multiply1;      //xy=557,73
AudioAnalyzeFFT1024      fft1024_1;      //xy=557.7777557373047,24.444462776184082
AudioEffectMultiply      multiply2;      //xy=562,236
AudioPlaySdWav           playSdWav1;     //xy=705,152
AudioEffectEnvelope      envelope1;      //xy=708,75
AudioEffectEnvelope      envelope2;      //xy=712,237
AudioMixer4              mixer3;         //xy=900.7777786254883,105.77777862548828
AudioMixer4              mixer4;         //xy=903.0000038146973,215.66666221618652
AudioOutputI2S           i2s2;           //xy=1042.2222222222222,152.22222222222223
AudioConnection          patchCord1(i2s1, 0, mixer1, 0);
AudioConnection          patchCord2(i2s1, 1, mixer2, 0);
AudioConnection          patchCord3(sine1, 0, multiply1, 1);
AudioConnection          patchCord4(sine1, 0, multiply2, 0);
AudioConnection          patchCord5(mixer1, 0, multiply1, 0);
AudioConnection          patchCord6(mixer1, fft1024_1);
AudioConnection          patchCord7(mixer2, 0, multiply2, 1);
AudioConnection          patchCord8(multiply1, envelope1);
AudioConnection          patchCord9(multiply2, envelope2);
AudioConnection          patchCord10(playSdWav1, 0, mixer3, 1);
AudioConnection          patchCord11(playSdWav1, 1, mixer4, 1);
AudioConnection          patchCord12(envelope1, 0, mixer3, 0);
AudioConnection          patchCord13(envelope2, 0, mixer4, 0);
AudioConnection          patchCord14(mixer3, 0, i2s2, 0);
AudioConnection          patchCord15(mixer4, 0, i2s2, 1);
AudioControlSGTL5000     sgtl5000_1;     //xy=385.55555555555554,342.22222222222223
// GUItool: end automatically generated code


const byte ROWS = 4; //four rows
const byte COLS = 3; //three columns
char keys[ROWS][COLS] = {
  {'1','2','3'},
  {'4','5','6'},
  {'7','8','9'},
  {'*','0','#'}
};
byte rowPins[ROWS] = {6, 5, 4, 3};
byte colPins[COLS] = {2,1,0};

Keypad keypad = Keypad( makeKeymap(keys), rowPins, colPins, ROWS, COLS );

// DANGER.WAV
// R2D2.WAV
// YOURCMD.WAV
// HENRY.WAV
// THANKS.WAV
// TRICK.WAV
// TRICKL.WAV
// BREATH.WAV
// BURP.WAV
// CARHORN.WAV
// CRUNCH.WAV
// DANGER.WAV
// DESTROY.WAV
// DOOR.WAV
// FOGHORN.WAV
// HENRY.WAV
// HITHERE.WAV
// R2D2.WAV
// SABER.WAV
// SMELL.WAV
// SQUIRREL.WAV
// STARTUP.WAV
// THANKS.WAV
// TRICK.WAV
// TRICKL.WAV
// YOURCMD.WAV
// ZILLA.WAV

// Keypad/WAV information.  Number of elements here should match the
// number of keypad rows times the number of columns, plus one:
const char *sound[] = {
  "HENRY.WAV",   "TRICK.WAV",    "THANKS.WAV",
  "DANGER.WAV",  "R2D2.WAV",     "YOURCMD.WAV",
  "CARHORN.WAV", "BURP.WAV",     "FOGHORN.WAV",
  "HITHERE.WAV", "SQUIRREL.WAV", "SMELL.WAV",
  "STARTUP.WAV" };              // extra item = boot sound

// SD Card (Teensy Audio Shield Rev D)
#define SDCARD_CS_PIN    10
#define SDCARD_MOSI_PIN  11
#define SDCARD_SCK_PIN   12
// ILI9341 Color TFT Display connections
#define TFT_DC      16
#define TFT_CS      17
#define TFT_RST     14
#define TFT_MOSI    11
#define TFT_SCLK    13
#define TFT_MISO    12

ILI9341_t3 tft = ILI9341_t3(TFT_CS, TFT_DC, TFT_RST, TFT_MOSI, TFT_SCLK, TFT_MISO);

static int count = 0;
static uint16_t line_buffer[320];
static float scale = 1020.0;
static int micGainKnob = 0;     // reads A1
static int micGain = 42;         // computed value for micGain
static float vol = 0.8;

void setup(void) {
  Serial.begin(9600);

  AudioMemory(32);
  sgtl5000_1.enable();
  sgtl5000_1.volume(vol);
  sgtl5000_1.inputSelect(AUDIO_INPUT_MIC);
  sgtl5000_1.micGain(micGain);       // also adjusted by knob, below

  // Play with the frequency of the sine wave, lower == growlier
  sine1.frequency(30);
  // amplitude of sine wave is floating point number from 0 to 1
  sine1.amplitude(1.0);

  float mixer_gain = 0.7;// 0.75; //0.25
  mixer1.gain(0, mixer_gain);
  mixer2.gain(0, mixer_gain);

  mixer3.gain(0, 0.9);
  mixer3.gain(1, 0.2);
  mixer4.gain(0, 0.9);
  mixer4.gain(1, 0.2);

  envelope1.attack(1.5);
  envelope1.hold(5);
  envelope1.decay(20);
  envelope2.attack(1.5);
  envelope2.hold(5);
  envelope2.decay(20);

  fft1024_1.windowFunction(NULL);

  tft.begin();
  tft.fillScreen(ILI9341_BLACK);
  tft.setTextColor(ILI9341_YELLOW);
  tft.setTextSize(2);
  for (int i = 0; i < 100; i++) {
    tft.setScroll(count++);
    count = count % 320;
    delay(12);
  }
  tft.setRotation(0);

  SPI.setMOSI(SDCARD_MOSI_PIN);
  SPI.setSCK(SDCARD_SCK_PIN);
  if (!(SD.begin(SDCARD_CS_PIN))) {
    while (1) {
      Serial.println("Unable to access the SD card");
      delay(500);
    }
  }
  playSdWav1.play("STARTUP.WAV");
  delay(10); // wait for library to parse WAV info
}

void loop() {
  micGainKnob = analogRead(A1);
  micGain = (1024 - micGainKnob) / 4;
  sgtl5000_1.micGain(micGain); // range: 0-63
  Serial.print("MicGain: ");
  Serial.println(micGain);

  if (fft1024_1.available()) {
    for (int i = 0; i < 240; i++) {
      line_buffer[240 - i - 1] = colorMap(fft1024_1.output[i]);
    }
    tft.writeRect(0, count, 240, 1, (uint16_t*) &line_buffer);
    tft.setScroll(count++);
    count = count % 320;
  }

  if (! envelope1.isActive() && ! envelope2.isActive() ) {
    envelope1.noteOn();
    envelope2.noteOn();
  }

  char key = keypad.getKey();
  if (key != NO_KEY){
    if (key == '*') {
      vol = vol * 1.05;
      sgtl5000_1.volume(vol);
    }
    else if (key == '#') {
      vol = vol * 0.95;
      sgtl5000_1.volume(vol);
    }
    else {
      int i=0;
      switch (key) {
        case '1':
          i = 0;
          break;
        case '2':
          i = 1;
          break;
        case '3':
          i = 2;
          break;
        case '4':
          i = 3;
          break;
        case '5':
          i = 4;
          break;
        case '6':
          i = 5;
          break;
        case '7':
          i = 6;
          break;
        case '8':
          i = 7;
          break;
        case '9':
          i = 8;
          break;
          // case '*':
          //   i = 9;
          //   break;
        case '0':
          i = 10;
          break;
          // case '#':
          //   i = 11;
          //   break;
      }
      if (playSdWav1.isPlaying() == false) {
        Serial.println("Start playing");
        playSdWav1.play(sound[i]);
        delay(10); // wait for library to parse WAV info
      }
    }
  }
}

uint16_t colorMap(uint16_t val) {
  float red;
  float green;
  float blue;
  float temp = val / 65536.0 * scale;

  if (temp < 0.5) {
    red = 0.0;
    green = temp * 2;
    blue = 2 * (0.5 - temp);
  } else {
    red = temp;
    green = (1.0 - temp);
    blue = 0.0;
  }
  return tft.color565(red * 256, green * 256, blue * 256);
}



/* From the Teensy waterfall example:
   ---
   Waterfall Audio Spectrum Analyzer, adapted from Nathaniel Quillin's
   award winning (most over the top) Hackaday SuperCon 2015 Badge Hack.

   https://hackaday.io/project/8575-audio-spectrum-analyzer-a-supercon-badge
   https://github.com/nqbit/superconbadge

   ILI9341 Color TFT Display is used to display spectral data.
   Two pots on analog A2 and A3 are required to adjust sensitivity.

   Copyright (c) 2015 Nathaniel Quillin

   Permission is hereby granted, free of charge, to any person obtaining
   a copy of this software and associated documentation files
   (the "Software"), to deal in the Software without restriction,
   including without limitation the rights to use, copy, modify, merge,
   publish, distribute, sublicense, and/or sell copies of the Software,
   and to permit persons to whom the Software is furnished to do so,
   subject to the following conditions:

   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

// Keypad bits from:
// https://learn.adafruit.com/wave-shield-voice-changer

// Voice effects based on Dalek effect described here:
// https://forum.pjrc.com/threads/47157-Distort-Voice-to-Something-Scary-for-Halloween?p=157173&viewfull=1#post157173
