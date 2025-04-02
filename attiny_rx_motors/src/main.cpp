#include <Arduino.h>
#include <RH_ASK.h>
#include "radio_packet.h"

void halt_error();

// led defintions
#define PIN_LED      PB0

// radio definitions
#define BAUD         2000
#define PIN_RX       PB1

// motor driver definitions
#define PIN_MOTOR_A  PB3
#define PIN_MOTOR_B  PB4
#define PIN_FAULT    PB5

// sensor definitions
#define PIN_SENSOR   PB2

RH_ASK radio(BAUD, PIN_RX);

void setup() {

  pinMode(PIN_LED, OUTPUT);
  pinMode(PIN_SENSOR, INPUT);

  pinMode(PIN_MOTOR_A, OUTPUT);
  pinMode(PIN_MOTOR_B, OUTPUT);
  pinMode(PIN_FAULT, INPUT);
  
  if (!radio.init()) {
    halt_error();
  }
}

void loop() {

  if (radio.available()) {

  }  
}

// loop forever blinking the diagnostic LED quickly
void halt_error() {
  while(true) {
    digitalWrite(PIN_LED, LOW);
    delay(100);

    digitalWrite(PIN_LED, HIGH);
    delay(100);
  }
}