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
    interface Timer<TMilli> as SamplingTimer;
   	interface Timer<TMilli> as InvalidPathTimer;
    interface Packet;
    interface AMPacket;
    interface AMSend as AMMoteViewMsgSend;
    interface AMSend as AMPathCalcMsgSend;
    interface Receive as MoteViewMsgReceive;
    interface Receive as PathCalcMsgReceive;
  	interface SplitControl as AMControl;
  }
}

implementation {
	bool tempLoaded = FALSE;
	bool lightLoaded = FALSE;
	bool humLoaded = FALSE;
	bool volLoaded = FALSE;
	bool busy = FALSE;

  uint16_t temp;
  uint16_t light;
  uint16_t hum;
  uint16_t voltage;

	uint16_t counter = 0;
  uint16_t ledNum=0;
  uint16_t min_hop_count=MAX_NODE_COUNT;
  uint8_t address;
  int16_t next_hop=-1;

  void trySendOwnData();
  void transferPacket(MoteViewMsg* msg);
  void forwardPathCalcMsg(PathCalcMsg* msg);

  event void Boot.booted() {
    call AMControl.start();
    call InvalidPathTimer.startPeriodic(PATH_INVALID_FREQUENCY); 
    address = call AMPacket.address();
  }

  event void SamplingTimer.fired(){
   call Leds.set(1);
    
    if(next_hop<0)
    {
   call Leds.set(2);
      return; //Wait for PathCalc message 
    }
    tempLoaded = FALSE;
    lightLoaded = FALSE;
    humLoaded = FALSE;
    volLoaded = FALSE;
   call Leds.set(3);

    call VoltageRead.read();
    call LightRead.read();
    call TempRead.read();
    call HumRead.read();
  }

  event message_t* MoteViewMsgReceive.receive(message_t* message, void* payload, uint8_t len){
    if (len == sizeof(MoteViewMsg)) {
        MoteViewMsg* msg = (MoteViewMsg*)payload;
        transferPacket(msg);
      }
    
    return message;
  }
  event message_t* PathCalcMsgReceive.receive(message_t* message, void* payload, uint8_t len){
      if (len == sizeof(PathCalcMsg)) {
          PathCalcMsg* msg=(PathCalcMsg*)payload;
          uint8_t hop_count = msg->hop_count;
          uint8_t last_node=msg->path[hop_count-1];
          bool forward=FALSE;
          if(hop_count<min_hop_count){
            min_hop_count=hop_count;
            next_hop=last_node;
            forward=TRUE;
          }
          else if(hop_count == min_hop_count){
            if(last_node ==next_hop){
              forward=TRUE;
            }else{
              //Ignore...
            }
          }
          if(forward){
            msg->path[hop_count]=address;
            msg->hop_count=hop_count+1;
            forwardPathCalcMsg(msg);
          }
      }
      return message;
    }
  
	void trySendOwnData(){
  
    //call Leds.set(1);
		if(!busy)
    {
    //call Leds.set(2);
      if(tempLoaded && lightLoaded && humLoaded && volLoaded){
        message_t pkt;
        MoteViewMsg* mvpkt = (MoteViewMsg*)(call Packet.getPayload( &pkt, sizeof(MoteViewMsg)));
        if (mvpkt == NULL) {
          return;
        }
    //call Leds.set(3);
        mvpkt->nodeid = TOS_NODE_ID;
        mvpkt->counter = counter;
        mvpkt->temperature=temp;
        mvpkt->humidity=hum;
        mvpkt->light=light;
        mvpkt->voltage=voltage;
				if (call AMMoteViewMsgSend.send(next_hop, &pkt, sizeof(MoteViewMsg)) == SUCCESS) 
				{
        		busy = TRUE;
				}
			}
		}
    
    
	}

  void transferPacket(MoteViewMsg* msg){
    if(!busy)
    {
      message_t pkt;
      MoteViewMsg* mvpkt = (MoteViewMsg*)(call Packet.getPayload( &pkt, sizeof(MoteViewMsg)));
      if (mvpkt == NULL) {
        return;
      }
      mvpkt->nodeid = msg->nodeid;
      mvpkt->counter = msg->counter;
      mvpkt->voltage = msg->voltage;
      mvpkt->temperature = msg->temperature;
      mvpkt->humidity = msg->humidity;
      mvpkt->light = msg->light;

      if (call AMMoteViewMsgSend.send(next_hop, &pkt, sizeof(MoteViewMsg)) == SUCCESS) 
      {
          busy = TRUE;
      }
    }
  }

  void forwardPathCalcMsg(PathCalcMsg* msg){
    message_t pkt;
    uint16_t i=0;
    PathCalcMsg* snd_msg = (PathCalcMsg*)(call Packet.getPayload( &pkt, sizeof(PathCalcMsg)));
    while(i<msg->hop_count){
      snd_msg->path[i]=msg->path[i];
      i++;
    }
    
    snd_msg->type=msg->type;
    snd_msg->hop_count=msg->hop_count;
    
    if (call AMPathCalcMsgSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(PathCalcMsg)) == SUCCESS) 
    {
    }
  }
	
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call SamplingTimer.startPeriodic(SAMPLING_FREQUENCY);
    }
    else {
      call AMControl.start();
    }
  }

  event void InvalidPathTimer.fired(){
    min_hop_count=MAX_NODE_COUNT;
    next_hop=-1;
  }

	event void VoltageRead.readDone(error_t result,uint16_t data){
		if(result == SUCCESS){
      voltage = data;
      volLoaded=TRUE;
      trySendOwnData();
		}
	}

	event void LightRead.readDone(error_t result,uint16_t data){
		if(result == SUCCESS){
      light = data;
      lightLoaded=TRUE;
      trySendOwnData();
		}
	}

	event void TempRead.readDone(error_t result,uint16_t data){
		if(result == SUCCESS){
      temp = data;
      tempLoaded=TRUE;
      trySendOwnData();
		}
	}

	event void HumRead.readDone(error_t result,uint16_t data){
		if(result == SUCCESS){
      hum = data;
      humLoaded=TRUE;
      trySendOwnData();
		}
	}
	
	event void AMMoteViewMsgSend.sendDone(message_t* msg, error_t err) {
      counter++;
      busy = FALSE;
      if(ledNum == 0)
      {
        //call Leds.set(next_hop);
        //ledNum=next_hop;
      }
      else 
      {
        //call Leds.set(0);
        //ledNum=0;
      }
  }
  event void AMPathCalcMsgSend.sendDone(message_t* msg, error_t err) {
  }
  event void AMControl.stopDone(error_t err) {}
}