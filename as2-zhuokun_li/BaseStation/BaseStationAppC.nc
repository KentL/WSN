#include "../share/MoteView.h"

configuration BaseStationAppC{
	
}

implementation{
	components MainC;
	components BaseStationC as App;
  	components LedsC;
	components ActiveMessageC;
  	components SerialActiveMessageC;

	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.AMRadioControl -> ActiveMessageC;
	App.AMSerialControl -> SerialActiveMessageC;
	App.SerialSend->SerialActiveMessageC.AMSend[AM_SENSOR_DATA_MSG];
  	App.RadioReceive -> ActiveMessageC.Receive[AM_SENSOR_DATA_MSG];
  	App.SerialPacket->SerialActiveMessageC;
}