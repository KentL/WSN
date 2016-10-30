#ifndef MOTEVIEW_H
#define MOTEVIEW_H

enum {
  SAMPLING_FREQUENCY = 250,
  AM_SENSOR_DATA_MSG = 6,

};

typedef nx_struct MoteViewMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
  nx_uint16_t temperature;
  nx_uint16_t humidity;
  nx_uint16_t light;
  nx_uint16_t voltage;
} MoteViewMsg;

#endif