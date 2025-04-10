#include <Arduino.h>
#include <Arduino.h>
#include <Adafruit_NeoPixel.h>
#include <Adafruit_SSD1306.h>
#include <Adafruit_GFX.h>


#define LED_PIN DD2
#define KNOB_PIN A1
#define LED_COUNT 16
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 32


#define OLED_RESET     -1
#define SCREEN_ADDRESS 0x3C


Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);


Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);




void teststext(void) {
  display.clearDisplay();


  display.setTextSize(2); // Draw 2X-scale text
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(10, 0);
  uint16_t knob_value=analogRead(KNOB_PIN);
  uint8_t actual_knob_value= map(
       knob_value,
       0, 1023,
       0, 15
     );


  //display.println(F("test"));
  display.print(F("knob:"));
  display.println(knob_value);
  display.print(F("actual:"));
  display.println(actual_knob_value);
  display.display();      // Show initial text

  strip.clear();
  
  strip.setPixelColor(
    actual_knob_value,
    255,
    0,
    0
    );
  strip.show();


  delay(100);
}


void setup() {
  strip.begin();
  strip.show();
  pinMode(KNOB_PIN, INPUT);
  Serial.begin(9600);


  // SSD1306_SWITCHCAPVCC = generate display voltage from 3.3V internally
  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;);
  }
    // Clear the buffer
    display.clearDisplay();


}
uint8_t led_start=0;


void loop() {
  // put your main code here, to run repeatedly:
  teststext();
}
