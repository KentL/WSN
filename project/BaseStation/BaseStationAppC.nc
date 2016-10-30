#include "../share/MoteView.h"

configuration BaseStationAppC{
	
}


implementation{
	components MainC;
	components BaseStationC as App;
  	components LedsC;
	components ActiveMessageC;
  	components SerialActiveMessageC;
  	components new TimerMilliC();

	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.AMRadioControl -> ActiveMessageC;
	App.AMSerialControl -> SerialActiveMessageC;
	App.SerialSend->SerialActiveMessageC.AMSend[AM_MOTEVIEW_MSG];
  	App.MoteViewMsgReceive -> ActiveMessageC.Receive[AM_MOTEVIEW_MSG];
  	App.PathCalcMsgSend->ActiveMessageC.AMSend[AM_PATHCALC_MSG];
  	App.Packet->ActiveMessageC;
  	App.AMPacket->ActiveMessageC.AMPacket;
  	App.Timer->TimerMilliC;
}