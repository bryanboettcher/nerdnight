#include <avr/sleep.h>
#include <RH_ASK.h>
#include <TinyBME280.h>

#define DIAG_LED _BV(1)

#define BAUD_RATE 2000
#define RADIO_TX PB4
#define RADIO_EN PB5

struct sensor_packet {
  int32_t temperature;
  uint32_t pressure;
  uint32_t humidity;
  uint8_t sequence;
  uint8_t checksum;
} data;

RH_ASK radio(BAUD_RATE, 0, RADIO_TX, RADIO_EN);

void init_timer1() {
  // enable clk/16 prescaler, no PWM, no external pins
  TCCR1  = 0b00001001;

  // enable OCR1A, OCR1B, and OVF1 interrupts
  TIMSK |= 0b01100100;

  OCR1A = 64;  // 4x of /16, so clk/4
  OCR1B = 128; // 8x of /16, so clk/2
}

void init_sensor() {
  Wire.begin();
  BME280setI2Caddress(0x76);
  BME280setup();
}

void setup() {
  init_timer1();
  init_sensor();

  DDRB = DIAG_LED;

  radio.init();
  set_sleep_mode(SLEEP_MODE_IDLE);
  sei();
}

volatile uint8_t timer_led = 0;
volatile uint8_t timer_tx = 0;

uint8_t buffer[sizeof(data)] = {0};

void loop() {
  
  if (timer_led) {    
    timer_led = 0;

    data.temperature = BME280temperature();
    data.humidity = BME280humidity();
    data.pressure = BME280pressure();
  }

  if (timer_tx) {
    PORTB |= DIAG_LED;
    timer_tx = 0;

    data.sequence++;
    data.checksum = 0;

    memcpy(buffer, &data, sizeof(data));

    radio.send((uint8_t *) buffer, sizeof(buffer));
    radio.waitPacketSent();

    PORTB &= ~DIAG_LED;
  }

  sleep_mode();
}

volatile uint16_t timer1_overflow_a = 0;
ISR (TIMER1_COMPA_vect) {
  if (++timer1_overflow_a < 10)
    return;

  timer1_overflow_a = 0;
  timer_led = 1;
}

// volatile uint16_t timer1_overflow_b = 0;
// ISR (TIMER1_COMPB_vect) {
//   if (++timer1_overflow_b < 250)
//     return;
  
//   timer1_overflow_b = 0;
//   timer_tx = 1;
// }

int main() {
  setup();
  
  while(true) { loop(); }
}