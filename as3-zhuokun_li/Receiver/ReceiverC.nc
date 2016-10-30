#include "../share/PCRTest.h"
#include <UserButton.h>
module ReceiverC {
  uses 
  {
  	interface Boot;
   	interface Leds;
    interface SplitControl as AMRadioControl;
    interface Receive;
    interface AMSend;
    interface LogRead;
    interface LogWrite;
    interface Packet;
    interface Notify<button_state_t>;
    interface Timer<TMilli>;
  }
}

implementation {
  PCRTestMsg* buffer[TEST_COUNT];
  uint16_t rcv_count = 0;
  uint8_t mode= RECEIVER_MODE_LISTEN;
  message_t pkt;
  PCRResultMsg* result_msg;

	event void Boot.booted() {
    call AMRadioControl.start();
    call Notify.enable();
  }
	event void AMRadioControl.startDone(error_t err) {
    if (err == SUCCESS) {}
    else {
      call AMRadioControl.start();
    }
  }

  event void Notify.notify( button_state_t state ) {
     if ( state == BUTTON_PRESSED)
     {
        uint8_t rate;
        PCRResultMsg result;
        mode = RECEIVER_MODE_LOG;
        call Leds.set(1);
        rate = ((double)rcv_count)/TEST_COUNT*100;
        call LogWrite.erase();
        result.nodeid = TOS_NODE_ID;
        result.rate = rate;
        call LogWrite.append(&result, sizeof(PCRResultMsg));
     } 
     else if ( state == BUTTON_RELEASED)
     {
        mode = RECEIVER_MODE_OFFLOAD;
        call Leds.set(4);
        call Timer.startPeriodic(1000);
     }
  }
  event void Timer.fired(){
      //TODO: READ FROM LOG
      result_msg = (PCRResultMsg*)(call Packet.getPayload( &pkt, sizeof(PCRResultMsg)));
      call LogRead.read(&result_msg, sizeof(PCRResultMsg));
  }
  event void LogRead.readDone(void* buf, storage_len_t len, error_t err) {
   if ( (len == sizeof(PCRResultMsg)) && (buf == &result_msg) ) {
      call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(PCRResultMsg));
    }
  }
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (mode == RECEIVER_MODE_LISTEN && len == sizeof(PCRTestMsg)) {
      PCRTestMsg* rcvPkt = (PCRTestMsg*)payload;
      if(rcvPkt->nodeid == SENDER_ID)
        {
          buffer[rcv_count]=rcvPkt;
          rcv_count++; 
          if(rcv_count%2!=0)
          {
            call Leds.set(2);// turn green light on
          }
          else
          {
            call Leds.set(0);
          }   
        }
    }
    return msg;
  }	

  event void AMRadioControl.stopDone(error_t err) {}
   event void LogWrite.appendDone(void* buf, storage_len_t len,bool recordsLost, error_t err) {}
  event void AMSend.sendDone(message_t* msg, error_t err) {}
  event void LogWrite.eraseDone(error_t result) {}
  event void LogRead.seekDone(error_t err) {}
  event void LogWrite.syncDone(error_t err) {}

}