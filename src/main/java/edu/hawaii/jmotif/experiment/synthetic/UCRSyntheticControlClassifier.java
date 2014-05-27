package edu.hawaii.jmotif.experiment.synthetic;

import java.io.BufferedWriter;
import java.io.FileWriter;
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
 * Synthetic control experiment - exploring for best parameters through bruteforce.
 * 
 * @author psenin
 * 
 */
public class UCRSyntheticControlClassifier {

  // data locations
  private static final String TRAINING_DATA = "data/synthetic_control/synthetic_control_TRAIN";
  private static final String TEST_DATA = "data/synthetic_control/synthetic_control_TEST";

  // SAX parameters to use
  //
  private static int[] PAA_SIZES = { 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
      19, 20 };
  private static int[] ALPHABET_SIZES = { 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
      19, 20 };
  private static int[] WINDOW_SIZES = { 20, 24, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 55 };

  private static SAXCollectionStrategy strategy = SAXCollectionStrategy.NOREDUCTION;
  private static String strategyPrefix = "noreduction";

  /**
   * @param args
   * @throws TSException
   * @throws IndexOutOfBoundsException
   * @throws IOException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, TSException, IOException {

    // configuring strategy
    //
    String strategyP = args[0];
    if ("EXACT".equalsIgnoreCase(strategyP)) {
      strategy = SAXCollectionStrategy.EXACT;
      strategyPrefix = "exact";
    }
    if ("CLASSIC".equalsIgnoreCase(strategyP)) {
      strategy = SAXCollectionStrategy.CLASSIC;
      strategyPrefix = "classic";
    }

    // making training and test collections
    //
    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(TRAINING_DATA);
    Map<String, List<double[]>> testData = UCRUtils.readUCRData(TEST_DATA);

    // make up output fname
    //
    String outFname = "synthetic_control_" + strategyPrefix + ".csv";
    BufferedWriter bw = new BufferedWriter(new FileWriter(outFname));

    // iterate over parameters
    //
    for (int paaSize1 : PAA_SIZES) {
      for (int alphabetSize1 : ALPHABET_SIZES) {
        for (int windowSize1 : WINDOW_SIZES) {

          // no processing for PAA sizes larger than window sizes
          if (windowSize1 < paaSize1 + 1) {
            continue;
          }

          // making up the parameters array
          int[] params = new int[4];
          params[0] = windowSize1;
          params[1] = paaSize1;
          params[2] = alphabetSize1;
          params[3] = strategy.index();

          // making training bags collection
          List<WordBag> bags = TextUtils.labeledSeries2WordBags(trainData, params);

          // building TFIDF statistics for bags and normalizing weights vectors to unit ones
          HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
          tfidf = TextUtils.normalizeToUnitVectors(tfidf);

          // setting up counters
          int totalTestSample = 0;
          int totalPositiveTests = 0;

          // iterating over classes
          for (String currenClassUnderTest : testData.keySet()) {

            // these are series we are going to classify
            List<double[]> testD = testData.get(currenClassUnderTest);
            int positives = 0;

            // iterating over series set
            for (double[] series : testD) {
              positives = positives
                  + TextUtils.classify(currenClassUnderTest, series, tfidf, params);
              totalTestSample++;
            }

            // keep track for global accuracy
            totalPositiveTests = totalPositiveTests + positives;

          }

          // global accuracy
          double accuracy = (double) totalPositiveTests / (double) totalTestSample;
          double error = 1.0d - accuracy;

          String outStr = windowSize1 + "," + paaSize1 + "," + alphabetSize1 + "," + accuracy + ","
              + error;
          System.out.println(outStr);
          bw.write(outStr + "\n");

        }
      }
    }

    bw.close();
  }
}
