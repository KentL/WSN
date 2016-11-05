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
  bool mote_view_sender_busy = FALSE;
	bool path_calc_sender_busy = FALSE;

  uint16_t temp;
  uint16_t light;
  uint16_t hum;
  uint16_t voltage;

	uint16_t counter = 0;
  uint16_t ledNum=0;
  uint16_t min_hop_count=MAX_NODE_COUNT;
  uint8_t address;
  int16_t next_hop=-1;

  message_t mote_view_pkt;
  message_t path_calc_pkt;
  MoteViewMsg* mote_view_msg;
  PathCalcMsg* path_calc_msg;

  void trySendOwnData();
  void transferPacket(MoteViewMsg* msg);
  void forwardPathCalcMsg(PathCalcMsg* msg, uint8_t new_address, uint8_t new_hop_count);

  event void Boot.booted() {
    call AMControl.start();
    call InvalidPathTimer.startPeriodic(PATH_INVALID_FREQUENCY); 
    address = call AMPacket.address();

    
    mote_view_msg = (MoteViewMsg*)(call Packet.getPayload( &mote_view_pkt, sizeof(MoteViewMsg)));
    path_calc_msg = (PathCalcMsg*)(call Packet.getPayload( &path_calc_pkt, sizeof(PathCalcMsg)));
    if (mote_view_msg == NULL || path_calc_msg == NULL) 
    {
      return;
    }
  }

  event void SamplingTimer.fired(){
    if(next_hop<0)
    {
      if(ledNum == 0)
      {
        call Leds.set(6);
        ledNum=next_hop;
      }
      else 
      {
        call Leds.set(0);
        ledNum=0;
      }
      return; //Wait for PathCalc message 
    }
    tempLoaded = FALSE;
    lightLoaded = FALSE;
    humLoaded = FALSE;
    volLoaded = FALSE;

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
            forwardPathCalcMsg(msg,address,hop_count+1);
          }
      }
      return message;
    }
  
	void trySendOwnData(){
	    if(tempLoaded && lightLoaded && humLoaded && volLoaded)
	    {
          if(!mote_view_sender_busy && next_hop>0)
          {
    	        
    	        mote_view_msg->nodeid = TOS_NODE_ID;
    	        mote_view_msg->counter = counter;
    	        mote_view_msg->temperature=temp;
    	        mote_view_msg->humidity=hum;
    	        mote_view_msg->light=light;
    	        mote_view_msg->voltage=voltage;

      				if (call AMMoteViewMsgSend.send(next_hop, &mote_view_pkt, sizeof(MoteViewMsg)) == SUCCESS) 
      				{
      					mote_view_sender_busy = TRUE;
      				}
  			  }
		  }
	 }

  void transferPacket(MoteViewMsg* msg){
    if(!mote_view_sender_busy)
    {
      mote_view_msg->nodeid = msg->nodeid;
      mote_view_msg->counter = msg->counter;
      mote_view_msg->voltage = msg->voltage;
      mote_view_msg->temperature = msg->temperature;
      mote_view_msg->humidity = msg->humidity;
      mote_view_msg->light = msg->light;

      if (call AMMoteViewMsgSend.send(next_hop, &mote_view_pkt, sizeof(MoteViewMsg)) == SUCCESS) 
      {
          mote_view_sender_busy = TRUE;
      }
    }
  }

  void forwardPathCalcMsg(PathCalcMsg* msg, uint8_t new_address, uint8_t new_hop_count){
    if(!path_calc_sender_busy)
    {
      uint16_t i=0;
      while(i<msg->hop_count){
        path_calc_msg->path[i]=msg->path[i];
        i++;
      }
      path_calc_msg->type=msg->type;
      path_calc_msg->hop_count=new_hop_count;
      path_calc_msg->path[new_hop_count]=new_address;
      
      if (call AMPathCalcMsgSend.send(AM_BROADCAST_ADDR, &path_calc_pkt, sizeof(PathCalcMsg)) == SUCCESS) 
      {
        path_calc_sender_busy=TRUE;
      }
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
      mote_view_sender_busy = FALSE;
      if(ledNum == 0)
      {
        call Leds.set(next_hop);
        ledNum=next_hop;
      }
      else 
      {
        call Leds.set(0);
        ledNum=0;
      }
  }
  event void AMPathCalcMsgSend.sendDone(message_t* msg, error_t err) {
    path_calc_sender_busy=FALSE;
  }
  event void AMControl.stopDone(error_t err) {}
}