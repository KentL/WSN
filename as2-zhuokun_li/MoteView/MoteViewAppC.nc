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
	components new TimerMilliC() as Timer;
	components ActiveMessageC;

	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer -> Timer;
	App.TempRead -> TempHumSensor.Temperature;
	App.HumRead -> TempHumSensor.Humidity;
	App.VoltageRead -> VoltageSensor;
	App.LightRead -> LightSensor;
	App.Packet -> ActiveMessageC.Packet;
	App.AMControl -> ActiveMessageC;
    App.AMSend -> ActiveMessageC.AMSend[AM_SENSOR_DATA_MSG];
}