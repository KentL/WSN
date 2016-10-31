/**
 * Created by Kent Lee on 10/18/2016.
 */
import javax.swing.*;
import java.awt.*;
import java.util.Date;

public class SensorDataPanel extends JPanel {

    JTextField nodeIdTxt = new JTextField();
    JTextField rateTxt = new JTextField();
    JTextField lastUpdateTxt = new JTextField();
    

    public SensorDataPanel(){
        initTextFields();
        addTextFields();
    }
    public void setNodeIdTxt(String nodeId) {
        this.nodeIdTxt.setText(nodeId);
    }

    public void setRateTxt(String rate) {
        this.rateTxt.setText(rate);
    }

    public void setLastUpdateTimeTxt(String lastUpdateTime)
    {
        this.lastUpdateTxt.setText(lastUpdateTime);
    }
    
    private void initTextFields(){
        nodeIdTxt.setEditable(false);
        rateTxt.setEditable(false);
        lastUpdateTxt.setEditable(false);
    }
    private void addTextFields(){
        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);
        JLabel[] labels={
            new JLabel("Node ID:"),new JLabel("Rate(%):"), new JLabel("Time to last update:")
        };

        JTextField[] textFields={
            nodeIdTxt,rateTxt,lastUpdateTxt
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
