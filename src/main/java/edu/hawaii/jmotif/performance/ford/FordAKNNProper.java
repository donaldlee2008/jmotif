package edu.hawaii.jmotif.performance.ford;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.timeseries.TSException;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class FordAKNNProper extends UCRGenericClassifier {

  // data locations
  private static final String TRAINING_DATA = "data/ford/Ford_A_TRAIN";
  private static final String TEST_DATA = "data/ford/Ford_A_TEST";

  // SAX parameters to use
  //
  private static final int WINDOW_MIN = 52;
  private static final int WINDOW_MAX = 52;
  private static final int WINDOW_INCREMENT = 5;

  private static final int PAA_MIN = 8;
  private static final int PAA_MAX = 8;
  private static final int PAA_INCREMENT = 1;

  private static final int ALPHABET_MIN = 4;
  private static final int ALPHABET_MAX = 4;
  private static final int ALPHABET_INCREMENT = 1;

  private static SAXCollectionStrategy strategy = SAXCollectionStrategy.NOREDUCTION;
  private static String strategyPrefix = "noreduction";

  private static final int LEAVE_OUT_NUM = 100;
  private static final String outputPrefix = "ford_nfold_1";

  public FordAKNNProper() {
    super();
  }

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
    consoleLogger.fine("strategy: " + strategyPrefix);

    // make up window sizes
    int[] window_sizes = makeArray(WINDOW_MIN, WINDOW_MAX, WINDOW_INCREMENT);

    // make up paa sizes
    int[] paa_sizes = makeArray(PAA_MIN, PAA_MAX, PAA_INCREMENT);

    // make up alphabet sizes
    int[] alphabet_sizes = makeArray(ALPHABET_MIN, ALPHABET_MAX, ALPHABET_INCREMENT);

    // reading training and test collections
    //
    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(TRAINING_DATA);
    consoleLogger.fine("trainData classes: " + trainData.size() + ", series length: "
        + trainData.entrySet().iterator().next().getValue().get(0).length);
    for (Entry<String, List<double[]>> e : trainData.entrySet()) {
      consoleLogger.fine(" training class: " + e.getKey() + " series: " + e.getValue().size());
    }

    int totalTestSample = 0;
    Map<String, List<double[]>> testData = UCRUtils.readUCRData(TEST_DATA);
    consoleLogger.fine("testData classes: " + testData.size());
    for (Entry<String, List<double[]>> e : testData.entrySet()) {
      consoleLogger.fine(" test class: " + e.getKey() + " series: " + e.getValue().size());
      totalTestSample = totalTestSample + e.getValue().size();
    }

    Map<String, Entry<Double, int[][]>> parameters = trainKNNFold(window_sizes, paa_sizes,
        alphabet_sizes, strategy, trainData, LEAVE_OUT_NUM);

    BufferedWriter bw = new BufferedWriter(new FileWriter(outputPrefix + "_" + strategyP + ".csv"));
    for (Entry<String, Entry<Double, int[][]>> e : parameters.entrySet()) {
      bw.write(e.getKey().replace('_', ',') + "," + e.getValue().getKey() + "\n");
    }
    bw.close();

  }

}
