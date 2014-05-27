package edu.hawaii.jmotif.performance.adiac;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;

/**
 * Helper-runner for test.
 * 
 * @author psenin
 * 
 */
public class UCRAdiacWebProper extends UCRGenericClassifier {

  // data locations
  private static final String TRAINING_DATA = "data/Adiac/Adiac_TRAIN";
  private static final String TEST_DATA = "data/Adiac/Adiac_TEST";

  // SAX parameters to try
  //
  private static final int[][] params = { 
    { 60, 22, 12, EXACT }, { 60, 22, 12, NOREDUCTION }, { 60, 22, 12, CLASSIC },
    { 53, 23, 11, EXACT }, { 53, 23, 11, NOREDUCTION }, { 53, 23, 11, CLASSIC },
    { 70, 15, 16, EXACT }, { 70, 15, 16, NOREDUCTION }, { 70, 15, 16, CLASSIC },
    { 100, 24, 16, EXACT }, { 100, 24, 16, NOREDUCTION }, { 100, 24, 16, CLASSIC }
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
      // tfidf = TextUtils.normalizeToUnitVectors(tfidf);
      // EXACT,100,24,16,0.618925831202046,0.38107416879795397
      // NOREDUCTION,100,24,16,0.618925831202046,0.38107416879795397
      // CLASSIC,100,24,16,0.4859335038363171,0.5140664961636829

      BufferedWriter bw = new BufferedWriter(new FileWriter(new File("adiac_tfidf.csv")));
      bw.write(TextUtils.tfidfToTable(tfidf));
      bw.close();

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
