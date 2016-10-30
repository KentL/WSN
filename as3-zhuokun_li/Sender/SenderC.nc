#include "../share/PCRTest.h"

module SenderC {
  uses 
  {
  	interface Boot;
   	interface Leds;
   	interface Timer<TMilli>;
    interface Packet;
	  interface AMSend;
  	interface SplitControl as AMControl;
  }
}

implementation {
	message_t pkt;
	PCRTestMsg* test_msg;
	bool busy = FALSE;
  uint8_t counter=0;

	event void Boot.booted() {
		call AMControl.start();
  }

	event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer.startPeriodic(SENDING_FREQUENCY);
    }
    else {
      call AMControl.start();
    }
  }

	event void AMControl.stopDone(error_t err) {}

	event void Timer.fired(){

    if(counter<TEST_COUNT)
    {
      if(!busy){
        test_msg = (PCRTestMsg*)(call Packet.getPayload( &pkt, sizeof(PCRTestMsg)));
        if (test_msg == NULL) {
          return;
        }
        test_msg->nodeid = TOS_NODE_ID;
        test_msg->sequence = counter;
        if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(PCRTestMsg)) == SUCCESS)
        {
          busy=TRUE;
        }
        else{}
      }
    }
    else
    {
      call Leds.set(1); // Complete sending all test packets, turn red light on
    }
	}
	
	event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      counter++;
      busy = FALSE;
      call Leds.set((counter%2)*2);//Blink green light
    }
  }
}