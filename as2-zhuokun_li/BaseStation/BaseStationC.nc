#include "../share/MoteView.h"

module BaseStationC {
  uses 
  {
  	interface Boot;
   	interface Leds;
    interface SplitControl as AMRadioControl;
  	interface SplitControl as AMSerialControl;
    interface Receive as RadioReceive;
    interface AMSend as SerialSend;
    interface Packet as SerialPacket;
  }
}

implementation {
  message_t serialPkt;
	MoteViewMsg* mvpkt;

	event void Boot.booted() {
    call AMRadioControl.start();
		call AMSerialControl.start();
  }
	event void AMRadioControl.startDone(error_t err) {
    if (err == SUCCESS) {}
    else {
      call AMRadioControl.start();
    }
  }
  event void AMSerialControl.startDone(error_t err) {
    if (err == SUCCESS) {}
    else {
      call AMSerialControl.start();
    }
  }

  event void AMRadioControl.stopDone(error_t err) {}
	event void AMSerialControl.stopDone(error_t err) {}
  event void SerialSend.sendDone(message_t* msg, error_t err){}

  event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(MoteViewMsg)) {
      MoteViewMsg* rcvPkt = (MoteViewMsg*)payload;
      MoteViewMsg* sndPkg = (MoteViewMsg*)call SerialPacket.getPayload(&serialPkt, sizeof(MoteViewMsg));
      
      //Construct new packet
      if (sndPkg == NULL) {return;}
      if (call SerialPacket.maxPayloadLength() < sizeof(MoteViewMsg)) {
        return;
      }
      sndPkg->nodeid = rcvPkt->nodeid;
      sndPkg->counter = rcvPkt->counter;
      sndPkg->voltage = rcvPkt->voltage;
      sndPkg->temperature = rcvPkt->temperature;
      sndPkg->humidity = rcvPkt->humidity;
      sndPkg->light = rcvPkt->light;

      //Send packet to serial port
      if (call SerialSend.send(AM_BROADCAST_ADDR, &serialPkt, sizeof(MoteViewMsg)) == SUCCESS) 
      {
        call Leds.set(rcvPkt->nodeid);
      }else{
        call Leds.set(0);
      }
      
    }
    return msg;
  }	
}