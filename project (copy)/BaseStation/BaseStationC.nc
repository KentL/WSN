#include "../share/MoteView.h"

module BaseStationC {
  uses 
  {
  	interface Boot;
   	interface Leds;
    interface SplitControl as AMRadioControl;
  	interface SplitControl as AMSerialControl;
    interface Receive as MoteViewMsgReceive;
    interface AMSend as SerialSend;
    interface AMSend as PathCalcMsgSend;
    interface Packet;
    interface AMPacket;
    interface Timer<TMilli>;
  }
}

implementation {
  message_t serialPkt;
  message_t pathcalcPkt;
	MoteViewMsg* mvpkt;
  am_addr_t address;
  uint8_t ledNum=0;

	event void Boot.booted() {
    call AMRadioControl.start();
		call AMSerialControl.start();
    address = call AMPacket.address();
  }
	event void AMRadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
        call Timer.startPeriodic(PATHCALC_FREQUENCY);
    }
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

  event void Timer.fired(){
      PathCalcMsg* sndPkg = (PathCalcMsg*)call Packet.getPayload(&pathcalcPkt, sizeof(PathCalcMsg));
      sndPkg->hop_count=1;
      sndPkg->type=AM_MOTEVIEW_MSG;
      sndPkg->path[0]=address;
      if (call PathCalcMsgSend.send(AM_BROADCAST_ADDR, &pathcalcPkt, sizeof(PathCalcMsg)) == SUCCESS) 
      {
        if(ledNum==0){
          call Leds.set(7);
          ledNum=7;
        }else{
          call Leds.set(0);
          ledNum=0;
        }
      }
  }

  event void AMRadioControl.stopDone(error_t err) {}
	event void AMSerialControl.stopDone(error_t err) {}
  event void SerialSend.sendDone(message_t* msg, error_t err){}
  event void PathCalcMsgSend.sendDone(message_t* msg, error_t err){}

  event message_t* MoteViewMsgReceive.receive(message_t* msg, void* payload, uint8_t len){
  	call Leds.set(6);
    if (len == sizeof(MoteViewMsg)) {
      MoteViewMsg* rcvPkt = (MoteViewMsg*)payload;
      MoteViewMsg* sndPkg = (MoteViewMsg*)call Packet.getPayload(&serialPkt, sizeof(MoteViewMsg));
      
      //Construct new packet
      if (sndPkg == NULL) {return;}
      if (call Packet.maxPayloadLength() < sizeof(MoteViewMsg)) {
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
        
      }
      
    }
    return msg;
  }	
}