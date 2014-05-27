package edu.hawaii.jmotif.performance.electricalDevices;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.timeseries.TSException;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class UCRedHC extends UCRGenericClassifier {

  // data locations
  //
  private static final String TRAINING_DATA = "data/ElectricDevices/ElectricDevices_TRAIN";
  private static final String TEST_DATA = "data/ElectricDevices/ElectricDevices_TEST";

  // SAX parameters to try
  //
  private static final int[][] params = { { 17, 13, 6, NOREDUCTION } };

  /**
   * Runnable.
   * 
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    // making training and test collections
    //
    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(TRAINING_DATA);
    Map<String, List<double[]>> testData = UCRUtils.readUCRData(TEST_DATA);

    Map<String, Map<String, Integer>> confusionMatrix = new HashMap<String, Map<String, Integer>>();
    for (String key : testData.keySet()) {
      confusionMatrix.put(key, new HashMap<String, Integer>());
    }

    // iterate over parameters
    //
    for (int[] p : params) {

      // converting back from easy encoding
      int WINDOW_SIZE = p[0];
      int PAA_SIZE = p[1];
      int ALPHABET_SIZE = p[2];
      SAXCollectionStrategy strategy = SAXCollectionStrategy.CLASSIC;
      if (EXACT == p[3]) {
        strategy = SAXCollectionStrategy.EXACT;
      }
      else if (NOREDUCTION == p[3]) {
        strategy = SAXCollectionStrategy.NOREDUCTION;
      }

      int[][] params = new int[1][4];
      params[0][0] = WINDOW_SIZE;
      params[0][1] = PAA_SIZE;
      params[0][2] = ALPHABET_SIZE;
      params[0][3] = strategy.index();

      // making training bags collection
      List<WordBag> bags = TextUtils.labeledSeries2WordBags(trainData, PAA_SIZE, ALPHABET_SIZE,
          WINDOW_SIZE, strategy);

      // getting TFIDF done
      HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);

      // normalize vectors
      tfidf = TextUtils.normalizeToUnitVectors(tfidf);

      // classifying
      int testSampleSize = 0;
      int positiveTestCounter = 0;

      for (String label : tfidf.keySet()) {
        List<double[]> testD = testData.get(label);
        for (double[] series : testD) {
          String assignedClass = classify(series, tfidf, params, strategy);
          if (label.equalsIgnoreCase(assignedClass)) {
            positiveTestCounter++;
          }
          else {
            Integer confusionCounter = confusionMatrix.get(label).get(assignedClass);
            if (null == confusionCounter) {
              confusionMatrix.get(label).put(assignedClass, 1);
            }
            else {
              confusionMatrix.get(label).put(assignedClass, confusionCounter + 1);
            }
          }
          testSampleSize++;
        }
      }

      // accuracy and error
      double accuracy = (double) positiveTestCounter / (double) testSampleSize;
      double error = 1.0d - accuracy;

      // report results
      System.out.println(toLogStr(p, accuracy, error));

      // and the matrix
      for (Entry<String, Map<String, Integer>> e : confusionMatrix.entrySet()) {
        StringBuffer sb = new StringBuffer();
        sb.append("Class:").append(e.getKey()).append(":");
        for (Entry<String, Integer> ei : e.getValue().entrySet()) {
          sb.append(ei.getKey()).append(":").append(ei.getValue()).append(",");
        }
        System.out.println(sb.toString());
      }
    }

  }

  private static String classify(double[] series, HashMap<String, HashMap<String, Double>> tfidf,
      int[][] params, SAXCollectionStrategy strategy) throws IndexOutOfBoundsException, TSException {

    WordBag test = TextUtils.seriesToWordBag("test", series, params[0]);

    double minDist = -1.0d;
    String className = "";
    for (Entry<String, HashMap<String, Double>> e : tfidf.entrySet()) {
      double dist = TextUtils.cosineSimilarity(test, e.getValue());
      if (dist > minDist) {
        className = e.getKey();
        minDist = dist;
      }
    }

    return className;
  }

}
