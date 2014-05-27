package edu.hawaii.jmotif.experiment.twopatterns;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.timeseries.TSException;

public class ContinousExperiment {

  public static void main(String[] args) throws IOException, IndexOutOfBoundsException, TSException {

    int trainLimit = Integer.valueOf(args[0]).intValue();

    Map<String, List<double[]>> trainData = UCRUtils.readUCRData("2patterns_TRAIN.csv");
    Map<String, List<double[]>> testData = UCRUtils.readUCRData("2patterns_TESTSHORT.csv");

    double error = 0D;
    long jmotifStart = 0L;
    long jmotifFinish = 0L;

    int testSampleSize = 0;
    int positiveTestCounter = 0;

    Map<String, List<double[]>> trainSeries = subset(trainData, trainLimit);

    jmotifStart = System.currentTimeMillis();

    // building vectors
    //
    List<WordBag> bags = TextUtils.labeledSeries2WordBags(trainSeries, 107, 12, 3,
        SAXCollectionStrategy.NOREDUCTION);
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
    tfidf = TextUtils.normalizeToUnitVectors(tfidf);

    for (String label : tfidf.keySet()) {
      List<double[]> testD = testData.get(label);
      for (double[] series : testD) {
        positiveTestCounter = positiveTestCounter
            + TextUtils.classify(label, series, tfidf, 107, 12, 3,
                SAXCollectionStrategy.NOREDUCTION);
        testSampleSize++;
      }
    }

    // accuracy and error
    double accuracy = (double) positiveTestCounter / (double) testSampleSize;
    error = 1.0d - accuracy;
    jmotifFinish = System.currentTimeMillis();

    System.out.println("error: " + error + ", time " + String.valueOf(jmotifFinish - jmotifStart));

  }

  private static Map<String, List<double[]>> subset(Map<String, List<double[]>> trainData,
      int trainLimit) {

    Map<String, List<double[]>> res = new HashMap<String, List<double[]>>();

    List<double[]> uu = new ArrayList<double[]>();
    int counter = 0;
    for (double[] a : trainData.get("uu")) {
      uu.add(a);
      counter++;
      if (counter > trainLimit) {
        break;
      }
    }
    res.put("uu", uu);

    List<double[]> du = new ArrayList<double[]>();
    counter = 0;
    for (double[] a : trainData.get("du")) {
      du.add(a);
      counter++;
      if (counter > trainLimit) {
        break;
      }
    }
    res.put("du", du);

    List<double[]> ud = new ArrayList<double[]>();
    counter = 0;
    for (double[] a : trainData.get("ud")) {
      ud.add(a);
      counter++;
      if (counter > trainLimit) {
        break;
      }
    }
    res.put("ud", ud);

    List<double[]> dd = new ArrayList<double[]>();
    counter = 0;
    for (double[] a : trainData.get("dd")) {
      dd.add(a);
      counter++;
      if (counter > trainLimit) {
        break;
      }
    }
    res.put("dd", dd);

    return res;
  }
}
