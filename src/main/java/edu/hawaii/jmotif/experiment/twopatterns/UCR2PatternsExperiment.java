package edu.hawaii.jmotif.experiment.twopatterns;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class UCR2PatternsExperiment extends UCRGenericClassifier {

  private static final int[][] params = { { 113, 13, 3, NOREDUCTION }, { 107, 12, 3, NOREDUCTION } };

  /**
   * Runnable.
   * 
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    // making training and test collections
    //
    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(args[0]);
    Map<String, List<double[]>> testData = UCRUtils.readUCRData(args[1]);

    // iterate over parameters
    //
    for (int[] p : params) {
      long jmotifStart = System.currentTimeMillis();
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
          positiveTestCounter = positiveTestCounter
              + TextUtils.classify(label, series, tfidf, PAA_SIZE, ALPHABET_SIZE, WINDOW_SIZE,
                  strategy);
          testSampleSize++;
        }
      }

      // accuracy and error
      double accuracy = (double) positiveTestCounter / (double) testSampleSize;
      double error = 1.0d - accuracy;

      long jmotifFinish = System.currentTimeMillis();

      // report results
      System.out.println(toLogStr(p, accuracy, error) + ", time "
          + String.valueOf(jmotifFinish - jmotifStart));
    }

  }

}
