package edu.hawaii.jmotif.performance.ford;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
public class FordBWebProper {

  private static int CLASSIC = 0;
  private static int EXACT = 1;
  private static int NOREDUCTION = 2;

  // data locations
  private static final String TRAINING_DATA = "data/ford/Ford_B_TRAIN";
  private static final String TEST_DATA = "data/ford/Ford_B_TEST";

  // SAX parameters to try
  //
  private static final int[][] params = { { 430, 10, 15, NOREDUCTION },
      { 430, 10, 17, NOREDUCTION } };

  /**
   * @param args
   * @throws TSException
   * @throws IndexOutOfBoundsException
   * @throws IOException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, TSException, IOException {

    // making training and test collections
    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(TRAINING_DATA);
    Map<String, List<double[]>> testData = UCRUtils.readUCRData(TEST_DATA);

    for (int[] p : params) {

      // extract parameters
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
      HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
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

      double accuracy = (double) positiveTestCounter / (double) testSampleSize;
      double error = 1.0d - accuracy;

      System.out.println(WINDOW_SIZE + "," + PAA_SIZE + "," + ALPHABET_SIZE + "," + accuracy + ","
          + error);
      // System.out.println(new CosineDistanceMatrix(tfidf).toString());
    }

  }

}
