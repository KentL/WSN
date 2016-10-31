
/**
 * Created by Kent Lee on 10/18/2016.
 */
import java.text.*;
import java.util.*;

public class ViewController implements DataSubscriber {
    private Window window;
    private DataReceiver dataReceiver;
    private Hashtable<Integer,Date> sensorLastUpdateTimeDict = new Hashtable<Integer,Date>();
    private final long TIMER_FREQ_MS=1000;
    public ViewController(Window window,DataReceiver dataReceiver){
        this.window=window;
        this.dataReceiver=dataReceiver;
    }

    public void start(){
        window.setup();
        dataReceiver.register(this);
        startTimer();
    }

    private void startTimer(){
        Timer timer=new Timer();
        timer.scheduleAtFixedRate(new TimerTask() {
          @Override
          public void run() {
            Date now=new Date();
            for (int key : sensorLastUpdateTimeDict.keySet()) {
                Date lastUpdateTime=sensorLastUpdateTimeDict.get(key);
                long seconds = (now.getTime()-lastUpdateTime.getTime())/1000;
                SensorDataPanel sensorDataPanel = window.getSensorDataPanel(key);
                if (sensorDataPanel != null){
                    sensorDataPanel.setLastUpdateTimeTxt(""+seconds);
                }
            }
          }
        }, TIMER_FREQ_MS, TIMER_FREQ_MS);
    }
    
    public void handleData(PCRResultMsg msg) {
        System.out.println("Data updated");
        int nodeId=msg.get_nodeid();
        int rate = msg.get_rate();
        
        sensorLastUpdateTimeDict.put(nodeId,new Date());
        
        SensorDataPanel sensorDataPanel = window.getSensorDataPanel(nodeId);
        if (sensorDataPanel == null)
            sensorDataPanel = window.addSensorPanel(nodeId);

        NumberFormat formatter = new DecimalFormat("#0.00"); 
        sensorDataPanel.setNodeIdTxt(nodeId+"");
        sensorDataPanel.setRateTxt(rate+"");

        window.update();
    }
}
