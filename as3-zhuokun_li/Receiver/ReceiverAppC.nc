#include "../share/PCRTest.h"
#include "StorageVolumes.h"

configuration ReceiverAppC{
	
}

implementation{
	components MainC;
	components ReceiverC as App;
  	components LedsC;
	components new LogStorageC(VOLUME_RECEIVERLOG,TRUE); 
	components ActiveMessageC;
	components UserButtonC;
	components new TimerMilliC() as Timer;

	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.AMRadioControl -> ActiveMessageC;
  	App.Receive -> ActiveMessageC.Receive[AM_PCR_TEST_MSG];
    App.AMSend -> ActiveMessageC.AMSend[AM_PCR_RESULT_MSG];
  	App.LogRead->LogStorageC;
  	App.LogWrite->LogStorageC;
  	App.Notify->UserButtonC;
	App.Packet -> ActiveMessageC.Packet;
	App.Timer->Timer;
}