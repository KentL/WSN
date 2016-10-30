/**
 * Created by Kent Lee on 10/18/2016.
 */
import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class SensorsMonitor {
    private static void usage() {
      System.err.println("usage: SensorsMonitor [-comm <source> AMType]");
  	}
    public static void main(String[] args){
    	String source = null;
      if (args.length == 3) {
        if (!args[0].equals("-comm")) {
          usage();
          System.exit(1);
        }
        source = args[1];
      }
      else if (args.length != 0) {
        usage();
        System.exit(1);
      }
      int amType=-1;
      try{
        amType=Integer.parseInt(args[2]);
      }catch(Exception ex){
        usage();
        System.exit(1);
      }
      PhoenixSource phoenix;
      
      if (source == null) {
        phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
      }
      else {
        phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
      }

      MoteIF mif = new MoteIF(phoenix);

      Window window=new Window();
      DataReceiver dataReceiver = new DataReceiver(mif,amType);
      ViewController viewController=new ViewController(window,dataReceiver);
      viewController.start();
    }
}
