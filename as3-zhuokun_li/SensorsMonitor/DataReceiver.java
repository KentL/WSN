import java.util.ArrayList;
import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;
/**
 * Created by Kent Lee on 10/18/2016.
 */
public class DataReceiver implements net.tinyos.message.MessageListener  {
    private ArrayList<DataSubscriber> dataSubscribers = new ArrayList<DataSubscriber>();
    private MoteIF moteIF;

    public DataReceiver(MoteIF moteIF, int amType){
        PCRResultMsg instance = new PCRResultMsg();
        instance.amTypeSet(amType);
    	this.moteIF=moteIF;
        this.moteIF.registerListener(instance, this);
    }
    public void register(DataSubscriber subscriber){
        dataSubscribers.add(subscriber);
    }
    public void messageReceived(int to, Message message) {
        PCRResultMsg msg=(PCRResultMsg)message;
        System.out.println(msg.toString());
        for (DataSubscriber subscriber: dataSubscribers ) {
                subscriber.handleData(msg);
        }
    }
}
