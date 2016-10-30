#include "../share/MoteView.h"

configuration MoteViewAppC{
	
}

implementation{
	components MainC;
	components MoteViewC as App;
  	components LedsC;
  	components new HamamatsuS10871TsrC() as LightSensor;
  	components new SensirionSht11C() as TempHumSensor;
  	components new DemoSensorC() as VoltageSensor;
	components new TimerMilliC() as Timer0;
	components new TimerMilliC() as Timer1;
	components ActiveMessageC;

	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.SamplingTimer -> Timer0;
	App.InvalidPathTimer -> Timer1;
	App.TempRead -> TempHumSensor.Temperature;
	App.HumRead -> TempHumSensor.Humidity;
	App.VoltageRead -> VoltageSensor;
	App.LightRead -> LightSensor;
	App.Packet -> ActiveMessageC.Packet;
	App.AMPacket -> ActiveMessageC.AMPacket;
	App.AMControl -> ActiveMessageC;
    App.AMMoteViewMsgSend -> ActiveMessageC.AMSend[AM_MOTEVIEW_MSG];
    App.AMPathCalcMsgSend -> ActiveMessageC.AMSend[AM_PATHCALC_MSG];
    App.MoteViewMsgReceive -> ActiveMessageC.Receive[AM_MOTEVIEW_MSG];
    App.PathCalcMsgReceive -> ActiveMessageC.Receive[AM_PATHCALC_MSG];
}