#include "../share/MoteView.h"

module MoteViewC {
  uses 
  {
  	interface Boot;
   	interface Leds;
   	interface Read<uint16_t> as VoltageRead;
   	interface Read<uint16_t> as LightRead;
   	interface Read<uint16_t> as TempRead;
   	interface Read<uint16_t> as HumRead;
   	interface Timer<TMilli>;
    interface Packet;
	  interface AMSend;
  	interface SplitControl as AMControl;
  }
}

implementation {
	message_t pkt;
	MoteViewMsg* mvpkt;
	bool tempLoaded = FALSE;
	bool lightLoaded = FALSE;
	bool humLoaded = FALSE;
	bool volLoaded = FALSE;
	bool busy = FALSE;
	uint16_t counter = 0;
  uint16_t ledNum=0;

	void trySend(){
  		if(tempLoaded && lightLoaded && humLoaded && volLoaded){
  			if(!busy)
  			{
  				if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(MoteViewMsg)) == SUCCESS) 
  				{
	        		busy = TRUE;
  				}
  			}
  		}
  	}
	event void Boot.booted() {
		call AMControl.start();
  	}
  	event void AMControl.startDone(error_t err) {
	    if (err == SUCCESS) {
	      call Timer.startPeriodic(SAMPLING_FREQUENCY);
	    }
	    else {
	      call AMControl.start();
	    }
  }

	event void AMControl.stopDone(error_t err) {}

	event void Timer.fired(){
		mvpkt = (MoteViewMsg*)(call Packet.getPayload( &pkt, sizeof(MoteViewMsg)));
		if (mvpkt == NULL) {
		  return;
	  }
		mvpkt->nodeid = TOS_NODE_ID;
    mvpkt->counter = counter;

    tempLoaded = FALSE;
		lightLoaded = FALSE;
		humLoaded = FALSE;
		volLoaded = FALSE;

		call VoltageRead.read();
		call LightRead.read();
		call TempRead.read();
		call HumRead.read();
	}
	event void VoltageRead.readDone(error_t result,uint16_t data){
		if(result == SUCCESS){
      mvpkt->voltage = data;
      volLoaded=TRUE;
      trySend();
		}
	}
	event void LightRead.readDone(error_t result,uint16_t data){
		if(result == SUCCESS){
      mvpkt->light = data;
      lightLoaded=TRUE;
      trySend();
		}
	}
	event void TempRead.readDone(error_t result,uint16_t data){
		if(result == SUCCESS){
      mvpkt->temperature = data;
      tempLoaded=TRUE;
      trySend();
		}
	}
	event void HumRead.readDone(error_t result,uint16_t data){
		if(result == SUCCESS){
      mvpkt->humidity = data;
      humLoaded=TRUE;
      trySend();
		}
	}
	
	event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      counter++;
      busy = FALSE;
      if(ledNum == 0)
      {
        call Leds.set(TOS_NODE_ID);
        ledNum=TOS_NODE_ID;
      }
      else 
      {
        call Leds.set(0);
        ledNum=0;
      }
    }
  }
}