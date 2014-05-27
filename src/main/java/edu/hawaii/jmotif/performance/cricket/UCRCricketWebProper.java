package edu.hawaii.jmotif.performance.cricket;

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
public class UCRCricketWebProper extends UCRGenericClassifier {

  // data locations
  //
  private static final String TRAINING_DATA = "data/Cricket/Cricket_TRAIN";
  private static final String TEST_DATA = "data/Cricket/Cricket_TEST";
//   private static final String TEST_DATA = "data/Cricket/Cricket_new_TEST";

  // SAX parameters to try
  //
//  private static final int[][] params = { 
//      { 100,13,4, CLASSIC }, { 100,13,4, EXACT }, { 100,13,4, NOREDUCTION },
//      { 165,10,4, CLASSIC }, { 165,10,4, EXACT }, { 165,10,4, NOREDUCTION },
//    { 100,13,2, CLASSIC }, { 100,13,2, EXACT }, { 100,13,2, NOREDUCTION },
//    { 255,13,2, CLASSIC }, { 255,13,2, EXACT }, { 255,13,2, NOREDUCTION },
//    { 65,10,2, CLASSIC }, { 65,10,2, EXACT }, { 65,10,2, NOREDUCTION },
//    { 95,19,2, CLASSIC }, { 95,19,2, EXACT }, { 95,19,2, NOREDUCTION },
//  };

   private static final int[][] params = { 
   { 165,10,4, CLASSIC }, { 165,10,4, EXACT }, { 165,10,4, NOREDUCTION },
   { 103,4,8, CLASSIC }, { 103,4,8, EXACT }, { 103,4,8, NOREDUCTION },
};
   
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

      // report results
      System.out.println(toLogStr(p, accuracy, error));
    }

  }

}
