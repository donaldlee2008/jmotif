package edu.hawaii.jmotif.experiment.synthetic;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.CosineDistanceMatrix;
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
public class UCRSyntheticControlWebExample {

  // prefix for all of the output
  private static final String TRAINING_DATA = "data/synthetic_control/synthetic_control_TRAIN";
  private static final String TEST_DATA = "data/synthetic_control/synthetic_control_TEST";

  // SAX parameters to use
  //
  private static int WINDOW_SIZE = 40;
  private static int PAA_SIZE = 6;
  private static int ALPHABET_SIZE = 7;

  // 8,4,38

  private static SAXCollectionStrategy strategy = SAXCollectionStrategy.EXACT;

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

    // making training bags collection
    List<WordBag> bags = TextUtils.labeledSeries2WordBags(trainData, PAA_SIZE, ALPHABET_SIZE,
        WINDOW_SIZE, strategy);
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
    tfidf = TextUtils.normalizeToUnitVectors(tfidf);

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

    System.out.println(new CosineDistanceMatrix(tfidf).toString());

  }

}
