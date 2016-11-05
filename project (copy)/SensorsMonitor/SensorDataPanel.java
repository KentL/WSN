/**
 * Created by Kent Lee on 10/18/2016.
 */
import javax.swing.*;
import java.awt.*;
import java.util.Date;

public class SensorDataPanel extends JPanel {

    JTextField nodeIdTxt = new JTextField();
    JTextField countTxt = new JTextField();
    JTextField lastUpdateTimeTxt = new JTextField();
    JTextField temperatureTxt = new JTextField();
    JTextField humidityTxt = new JTextField();
    JTextField voltageTxt = new JTextField();
    JTextField lightTxt = new JTextField();
    

    public SensorDataPanel(){
        initTextFields();
        addTextFields();
    }
    public void setNodeIdTxt(String nodeId) {
        this.nodeIdTxt.setText(nodeId);
    }

    public void setCountTxt(String count) {
        this.countTxt.setText(count);
    }

    public void setLastUpdateTimeTxt(String lastUpdateTime) {
        this.lastUpdateTimeTxt.setText(lastUpdateTime);
    }

    public void setTemperatureTxt(String temp) {
        this.temperatureTxt.setText(temp);
    }

    public void setHumidityTxt(String humidity) {
        this.humidityTxt.setText(humidity);
    }

    public void setVoltageTxt(String voltage) {
        this.voltageTxt.setText(voltage);
    }

    public void setLightTxt(String light) {
        this.lightTxt.setText(light);
    }
    private void initTextFields(){
        nodeIdTxt.setEditable(false);
        countTxt.setEditable(false);
        lastUpdateTimeTxt.setEditable(false);
        temperatureTxt.setEditable(false);
        humidityTxt.setEditable(false);
        voltageTxt.setEditable(false);
        lightTxt.setEditable(false);

    }
    private void addTextFields(){
        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);
        JLabel[] labels={
            new JLabel("Node ID:"),new JLabel("Package Count:"),new JLabel("Time to last update:"),
            new JLabel("Temperature(°C):"),new JLabel("Humidity:"),new JLabel("Voltage(V):"),
            new JLabel("Light(lx):")
        };

        JTextField[] textFields={
            nodeIdTxt,countTxt,lastUpdateTimeTxt,temperatureTxt,humidityTxt,voltageTxt,lightTxt
        };

       layout.setAutoCreateGaps(true);
       layout.setAutoCreateContainerGaps(true);

       GroupLayout.SequentialGroup hGroup = layout.createSequentialGroup();
       GroupLayout.ParallelGroup pGroup1=layout.createParallelGroup() ;
       GroupLayout.ParallelGroup pGroup2=layout.createParallelGroup() ;
       for (int i=0; i<labels.length;i++ ) {
            pGroup1.addComponent(labels[i]);
            pGroup2.addComponent(textFields[i]);
        } 
        hGroup.addGroup(pGroup1);
        hGroup.addGroup(pGroup2);
        layout.setHorizontalGroup(hGroup);

       GroupLayout.SequentialGroup vGroup = layout.createSequentialGroup();

       for (int i=0; i<labels.length;i++ ) {
            vGroup.addGroup(layout.createParallelGroup(GroupLayout.Alignment.BASELINE).addComponent(labels[i]).addComponent(textFields[i]));
        } 
       layout.setVerticalGroup(vGroup);
    }
    private void addFields(String name,JTextField textField){
        JPanel row = new JPanel();
        row.setLayout(new FlowLayout());
        JLabel label = new JLabel(name);
        label.setSize(10,label.getHeight());
        label.setHorizontalAlignment(SwingConstants.LEFT);
        row.add(label);
        row.add(textField);
        add(row);
    }
}
