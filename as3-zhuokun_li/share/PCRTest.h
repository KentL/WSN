#ifndef PCRTEST_H
#define PCRTEST_H

enum {
  SENDING_FREQUENCY = 1000,
  AM_PCR_TEST_MSG = 7,
  AM_PCR_RESULT_MSG = 6,
  TEST_COUNT=100,
  SENDER_ID=1,
  RECEIVER_MODE_LISTEN=0,
  RECEIVER_MODE_LOG=1,
  RECEIVER_MODE_OFFLOAD=2,
};

typedef nx_struct PCRTestMsg {
  nx_uint16_t nodeid;
  nx_uint16_t sequence;
} PCRTestMsg;

typedef nx_struct PCRResultMsg {
  nx_uint16_t nodeid;
  nx_uint16_t rate;
} PCRResultMsg;

#endif