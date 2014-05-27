package edu.hawaii.jmotif.performance.thorax;

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
public class UCRThorax1WebProper extends UCRGenericClassifier {

  // data locations
  //
  private static final String TRAINING_DATA = "data/NonInvasiveFatalECG/NonInvasiveFatalECG _Thorax1TRAIN.txt";
  private static final String TEST_DATA = "data/NonInvasiveFatalECG/NonInvasiveFatalECG _Thorax1TEST.txt";

   private static final int[][] params = { 
     
     { 44,15,14,NOREDUCTION },{ 44,15,14, EXACT }, { 44,15,14, CLASSIC },
     { 348,15,10,NOREDUCTION },{ 348,15,10, EXACT }, { 348,15,10, CLASSIC },
     { 348,15,12,NOREDUCTION },{ 348,15,12, EXACT }, { 348,15,12, CLASSIC },
     { 376,14,7,NOREDUCTION },{ 376,14,7, EXACT }, { 376,14,7, CLASSIC },
   { 376,15,10,NOREDUCTION },{ 376,15,10, EXACT }, { 376,15,10, CLASSIC }
   
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
