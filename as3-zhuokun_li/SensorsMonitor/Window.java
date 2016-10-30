/**
 * Created by Kent Lee on 10/18/2016.
 */

import javax.swing.*;
import javax.swing.table.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;

public class Window {
    private JFrame frame;
    private JPanel main;
    private JPanel wrapper;
    private Hashtable<Integer,SensorDataPanel> sensorDataPanelDictionary = new Hashtable<Integer,SensorDataPanel>();
    void setup() {
        main = new JPanel(new BorderLayout());

        main.setMinimumSize(new Dimension(500, 250));
        main.setPreferredSize(new Dimension(800, 400));
        main.setLayout(new BorderLayout());

        // The frame part
        frame = new JFrame("SensorsMonitor");
        frame.setSize(main.getPreferredSize());
        frame.getContentPane().add(main);
        frame.setVisible(true);
        frame.addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent e) {
                System.exit(0);
            }
        });
        wrapper = new JPanel();
        wrapper.setLayout(new FlowLayout());
        main.add(wrapper,BorderLayout.WEST);
    }
    void update()
    {
        frame.invalidate();
        frame.validate();
        frame.repaint();
    }
    public SensorDataPanel addSensorPanel(int sensorId){
        System.out.println("new Panel #"+sensorId+" added.");
        SensorDataPanel sensorDataPanel = new SensorDataPanel();
        sensorDataPanelDictionary.put(sensorId,sensorDataPanel);
        wrapper.add(sensorDataPanel);
        return sensorDataPanel;
    }

    public SensorDataPanel getSensorDataPanel(int sensorId){
        return sensorDataPanelDictionary.get(sensorId);
    }

}
