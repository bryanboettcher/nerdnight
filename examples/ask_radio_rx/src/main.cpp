#include <Arduino.h>
#include <RH_ASK.h>
#include <SPI.h>

#define BAUD_RATE 2000
#define RADIO_RX DD2

struct sensor_packet {
  int32_t temperature;
  uint32_t pressure;
  uint32_t humidity;
  uint8_t sequence;
  uint8_t checksum;
} data;

RH_ASK radio(BAUD_RATE, RADIO_RX);

void setup() {
  delay(250);
  Serial.begin(9600);
  
  if(radio.init()) {
    Serial.println("Radio initialized");
  } else {
    Serial.println("Radio failed to initialize");
    while(1);
  }
}

void loop() {
  uint8_t buffer[RH_ASK_MAX_MESSAGE_LEN];
  uint8_t buffer_length = sizeof(buffer);

  if (radio.available()) {
    if (radio.recv(buffer, &buffer_length)) {
      memcpy(&data, buffer, buffer_length);

      Serial.println("Received message: ");
      
      Serial.print("Sequence: ");
      Serial.println(data.sequence);
      Serial.print("Temperature: ");
      Serial.println(data.temperature);
      Serial.print("Pressure: ");
      Serial.println(data.pressure);
      Serial.print("Humidity: ");
      Serial.println(data.humidity);
      
    } else {
      Serial.print("Receive failed, size: ");
      Serial.println(buffer_length);
    }
  }

  delay(50);
}
