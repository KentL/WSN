#ifndef MOTEVIEW_H
#define MOTEVIEW_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
enum {
  SAMPLING_FREQUENCY = 1000,
  PATHCALC_FREQUENCY = 3000,
  PATH_INVALID_FREQUENCY=15000,
  AM_MOTEVIEW_MSG = 6,
  AM_PATHCALC_MSG = 7,
  MAX_NODE_COUNT=10,
};

typedef nx_struct MoteViewMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
  nx_uint16_t temperature;
  nx_uint16_t humidity;
  nx_uint16_t light;
  nx_uint16_t voltage;
} MoteViewMsg;

typedef nx_struct PathCalcMsg {
  nx_uint8_t type;
  nx_uint8_t hop_count;
  nx_uint8_t path[MAX_NODE_COUNT];
}PathCalcMsg;

 #endif
// if (len == sizeof(MoteViewMsg)) {
//       MoteViewMsg* msg = (MoteViewMsg*)payload;
//       transferPacket(msg);
//     }
//     else if (len == sizeof(PathCalcMsg)) {
//       PathCalcMsg* msg=(PathCalcMsg*)payload;
//       uint8_t hop_count = msg->hop_count;
//       uint8_t last_node=msg->path[hop_count-1];
//       bool forward=FALSE;
//       if(hop_count<min_hop_count){
//         min_hop_count=hop_count;
//         next_hop=last_node;
//         forward=TRUE;
//       }
//       else if(hop_count == min_hop_count){
//         if(last_node ==next_hop){
//           forward=TRUE;
//         }else{
//           //Ignore...
//         }
//       }
//       if(forward){
//         msg->path[hop_count]=address;
//         msg->hop_count=hop_count+1;
//         forwardPathCalcMsg(msg);
//       }
//     }