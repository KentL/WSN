#include "../share/PCRTest.h"

module BaseStationC {
  uses 
  {
  	interface Boot;
   	interface Leds;
    interface SplitControl as AMRadioControl;
  	interface SplitControl as AMSerialControl;
    interface Receive;
    interface AMSend as SerialSend;
    interface Packet as SerialPacket;
  }
}

implementation {
  message_t serialPkt;
  int count=0;
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

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(PCRResultMsg)) {
      PCRResultMsg* rcvPkt = (PCRResultMsg*)payload;
      PCRResultMsg* sndPkg = (PCRResultMsg*)call SerialPacket.getPayload(&serialPkt, sizeof(PCRResultMsg));
      
      call Leds.set(6);
      //Construct new packet
      if (sndPkg != NULL && call SerialPacket.maxPayloadLength() >= sizeof(PCRResultMsg))
      {
        sndPkg->nodeid = rcvPkt->nodeid;
        sndPkg->rate = rcvPkt->rate;
        
        call Leds.set(4);
        //Send packet to serial port
        if (call SerialSend.send(AM_BROADCAST_ADDR, &serialPkt, sizeof(PCRResultMsg)) == SUCCESS) 
        {
          count++;
          call Leds.set(count);
        }else{
          call Leds.set(7);
        }
      }
    }
    return msg;
  }	


  event void AMRadioControl.stopDone(error_t err) {}
  event void AMSerialControl.stopDone(error_t err) {}
  event void SerialSend.sendDone(message_t* msg, error_t err){}
}