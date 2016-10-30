#include "../share/PCRTest.h"

configuration SenderAppC{
	
}

implementation{
	components MainC;
	components SenderC as App;
  	components LedsC;
	components new TimerMilliC() as Timer;
	components ActiveMessageC;

	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer -> Timer;
	App.Packet -> ActiveMessageC.Packet;
	App.AMControl -> ActiveMessageC;
    App.AMSend -> ActiveMessageC.AMSend[AM_PCR_TEST_MSG];
}