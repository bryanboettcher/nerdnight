#ifndef RADIO_PACKET_H
#define RADIO_PACKET_H

#include <Arduino.h>

struct radio_packet {
    uint32_t node_id;
    uint8_t group_id;
    int8_t position;
};

#endif