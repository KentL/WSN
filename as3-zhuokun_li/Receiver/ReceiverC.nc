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
  PCRResultMsg logged_result;
  bool log_done=FALSE;
  PCRResultMsg pcr_result;
  bool busy=FALSE;

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

  void enter_log_mode()
  {
      mode = RECEIVER_MODE_LOG;
      call Leds.set(1); // Turn red light on
      call LogWrite.erase(); // Clear previous log, then log this result
  }
  event void Timer.fired()
  {
    if(!busy)
    {
      call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(PCRResultMsg));
      busy=TRUE;
    }
  }
  void enter_offload_mode()
  {
      if(log_done)
      {
        mode = RECEIVER_MODE_OFFLOAD;
        call Leds.set(4); //Turn blue light on
      
        result_msg = (PCRResultMsg*)(call Packet.getPayload( &pkt, sizeof(PCRResultMsg)));
        call LogRead.read(&logged_result, sizeof(PCRResultMsg));
      }
  }
  event void Notify.notify( button_state_t state ) {
     if ( state == BUTTON_PRESSED)
     {
        if(mode == RECEIVER_MODE_LISTEN)
        {
          enter_log_mode();
        }
        else if(mode == RECEIVER_MODE_LOG)
        {
          enter_offload_mode();
        }
     } 
  }


  event void LogWrite.eraseDone(error_t result) 
  {
      uint8_t rate;
      rate = ((double)(rcv_count))/(double)TEST_COUNT*100;
      pcr_result.nodeid = TOS_NODE_ID;
      pcr_result.rate = rate;
      call LogWrite.append(&pcr_result, sizeof(PCRResultMsg));
  }
  
  event void LogRead.readDone(void* buf, storage_len_t len, error_t err) {
      if ( (len == sizeof(PCRResultMsg)) && (buf == &logged_result) ) {
        result_msg->nodeid = logged_result.nodeid;
        result_msg->rate = logged_result.rate;
        call Timer.startPeriodic(SENDING_FREQUENCY);
      }
  }
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (mode == RECEIVER_MODE_LISTEN && len == sizeof(PCRTestMsg)) {
      PCRTestMsg* rcvPkt = (PCRTestMsg*)payload;
      if(rcvPkt->nodeid == SENDER_ID)
        {
          buffer[rcv_count]=rcvPkt;
          rcv_count++; 
          call Leds.set((rcv_count%2)*2);// turn green light on
        }
    }
    return msg;
  }	

  event void AMRadioControl.stopDone(error_t err) {}
  event void LogWrite.appendDone(void* buf, storage_len_t len,bool recordsLost, error_t err) 
  {
    log_done=TRUE;
    call Leds.set(7);
  }
  event void AMSend.sendDone(message_t* msg, error_t err) {
    busy=FALSE;
  }

  event void LogRead.seekDone(error_t err) {}
  event void LogWrite.syncDone(error_t err) {}

}