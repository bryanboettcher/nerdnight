#include <Arduino.h>
#include <RH_ASK.h>
#include "radio_packet.h"

void init_timer();
void halt_error();
void handle_position(radio_packet packet);

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

uint8_t position_enable;
int8_t position_target;
int8_t position_current;

volatile uint8_t timer_position = 0;

void setup() {

  pinMode(PIN_LED, OUTPUT);
  pinMode(PIN_SENSOR, INPUT);

  pinMode(PIN_MOTOR_A, OUTPUT);
  pinMode(PIN_MOTOR_B, OUTPUT);
  pinMode(PIN_FAULT, INPUT);
  
  init_timer();

  position_enable = 0;

  if (!radio.init()) {
    halt_error();
  }
}

void loop() {

  if (radio.available()) {
    uint8_t buffer_size = sizeof(radio_packet);
    uint8_t buffer[buffer_size];
    
    if (radio.recv(buffer, &buffer_size)) {
      radio_packet packet;
      memcpy(&packet, buffer, buffer_size);

      handle_position(packet);
    }
  }

  if (timer_position) {
    update_position();
  }
}

void init_timer() {
  TCCR0A = 0;
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

// update the position values if this is ours
void handle_position(radio_packet packet) {
  
  // fake the "group" match
  if (packet.group_id) {
    position_target = packet.position;
    position_enable = (packet.position == 0);
  }
}

void update_position() {

  if (! position_enable)
    return;

  position_current = map(
    analogRead(PIN_SENSOR),
    0, 1024,
    -127, 127
  );

  if (position_current == 0)
    position_current = 1;

  if(position_current < position_target) {
    digitalWrite(PIN_MOTOR_A, HIGH);
    digitalWrite(PIN_MOTOR_B, LOW);
  } else {
    digitalWrite(PIN_MOTOR_A, LOW);
    digitalWrite(PIN_MOTOR_B, HIGH);
  }
}

ISR(TIMER0_OVF) {
  timer_position = 1;
}