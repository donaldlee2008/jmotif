package edu.hawaii.jmotif.performance.cbf;

import java.awt.BorderLayout;
import java.io.BufferedReader;
import java.io.FileReader;
import java.util.Random;
import weka.classifiers.Classifier;
import weka.classifiers.Evaluation;
import weka.classifiers.bayes.NaiveBayes;
import weka.classifiers.evaluation.ThresholdCurve;
import weka.core.Instances;
import weka.core.Utils;
import weka.gui.visualize.PlotData2D;
import weka.gui.visualize.ThresholdVisualizePanel;
import edu.hawaii.jmotif.performance.SAXVSMClassifier;

/**
 * Generates and displays a ROC curve from a dataset. Uses a default NaiveBayes to generate the ROC
 * data.
 * 
 * @author FracPete
 */
public class CBFROC {

  /**
   * takes one argument: dataset in ARFF format (expects class to be last attribute)
   */
  public static void main(String[] args) throws Exception {
    // load data
    Instances data = new Instances(new BufferedReader(new FileReader("data/gun.arff")));
    data.setClassIndex(data.numAttributes() - 1);

    // train classifier
    Classifier cl = new NaiveBayes();

    SAXVSMClassifier cl1 = new SAXVSMClassifier();
    cl1.setSAXParams(32, 12, 9, "CLASSIC");
    // cl1.setSAXParams(42, 5, 5, "CLASSIC"); // CBF

    // Evaluation eval = new Evaluation(data);
    // eval.crossValidateModel(cl, data, 8, new Random(1));

    Evaluation eval = new Evaluation(data);
    eval.crossValidateModel(cl1, data, 10, new Random(1));

    // generate curve
    ThresholdCurve tc = new ThresholdCurve();
    int classIndex = 0;
    Instances result = tc.getCurve(eval.predictions(), classIndex);

    // plot curve
    ThresholdVisualizePanel vmc = new ThresholdVisualizePanel();
    vmc.setROCString("(Area under ROC = "
        + Utils.doubleToString(ThresholdCurve.getROCArea(result), 4) + ")");
    vmc.setName(result.relationName());
    PlotData2D tempd = new PlotData2D(result);
    tempd.setPlotName(result.relationName());
    tempd.addInstanceNumberAttribute();

    // specify which points are connected
    boolean[] cp = new boolean[result.numInstances()];
    for (int n = 1; n < cp.length; n++)
      cp[n] = true;
    tempd.setConnectPoints(cp);
    // add plot
    vmc.addPlot(tempd);

    // display curve
    String plotName = vmc.getName();
    final javax.swing.JFrame jf = new javax.swing.JFrame("Weka Classifier Visualize: " + plotName);
    jf.setSize(500, 400);
    jf.getContentPane().setLayout(new BorderLayout());
    jf.getContentPane().add(vmc, BorderLayout.CENTER);
    jf.addWindowListener(new java.awt.event.WindowAdapter() {
      public void windowClosing(java.awt.event.WindowEvent e) {
        jf.dispose();
      }
    });
    jf.setVisible(true);
  }
}