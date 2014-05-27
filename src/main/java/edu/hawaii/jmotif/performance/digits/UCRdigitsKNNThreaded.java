package edu.hawaii.jmotif.performance.digits;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class UCRdigitsKNNThreaded extends UCRGenericClassifier {

  // num of threads to use
  //
  private static int THREADS_NUM = 16;

  // data
  //
  private static String TRAINING_DATA = "digits_normalized_reduced_200.csv";
  // private static final String TEST_DATA = "data/Gun_Point/Gun_Point_TEST";
  // output prefix
  //
  private static String outputPrefix = "digits_loocv_train";

  // SAX parameters to use
  //
  private static int WINDOW_MIN = 28;
  private static int WINDOW_MAX = 450;
  private static int WINDOW_INCREMENT = 10;

  private static int PAA_MIN = 5;
  private static int PAA_MAX = 60;
  private static int PAA_INCREMENT = 2;

  private static int ALPHABET_MIN = 3;
  private static int ALPHABET_MAX = 16;
  private static int ALPHABET_INCREMENT = 2;

  // leave out parameters
  //
  private static final int LEAVE_OUT_NUM = 10;

  private UCRdigitsKNNThreaded() {
    super();
  }

  /**
   * @param args
   * @throws Exception
   */
  public static void main(String[] args) throws Exception {

    TRAINING_DATA = args[0];

    THREADS_NUM = Integer.valueOf(args[1]);

    WINDOW_MIN = Integer.valueOf(args[2]);
    WINDOW_MAX = Integer.valueOf(args[3]);
    WINDOW_INCREMENT = Integer.valueOf(args[4]);

    PAA_MIN = Integer.valueOf(args[5]);
    PAA_MAX = Integer.valueOf(args[6]);
    PAA_INCREMENT = Integer.valueOf(args[7]);

    ALPHABET_MIN = Integer.valueOf(args[8]);
    ALPHABET_MAX = Integer.valueOf(args[9]);
    ALPHABET_INCREMENT = Integer.valueOf(args[10]);

    String strategyP = args[11];

    outputPrefix = args[12];

    // configuring strategy
    //
    SAXCollectionStrategy strategy = SAXCollectionStrategy.NOREDUCTION;
    String strategyPrefix = "noreduction";

    if ("EXACT".equalsIgnoreCase(strategyP)) {
      strategy = SAXCollectionStrategy.EXACT;
      strategyPrefix = "exact";
    }
    if ("CLASSIC".equalsIgnoreCase(strategyP)) {
      strategy = SAXCollectionStrategy.CLASSIC;
      strategyPrefix = "classic";
    }

    consoleLogger.fine("window: " + WINDOW_MIN + " -> " + WINDOW_MAX + ", by " + WINDOW_INCREMENT);
    consoleLogger.fine("paa: " + PAA_MIN + " -> " + PAA_MAX + ", by " + PAA_INCREMENT);
    consoleLogger.fine("alphabet: " + ALPHABET_MIN + " -> " + ALPHABET_MAX + ", by "
        + ALPHABET_INCREMENT);
    consoleLogger.fine("strategy: " + strategyPrefix + ", leaving out: " + LEAVE_OUT_NUM);

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

    List<String> result = trainKNNFoldJMotifThreaded(THREADS_NUM, window_sizes, paa_sizes,
        alphabet_sizes, strategy, trainData, LEAVE_OUT_NUM);

    BufferedWriter bw = new BufferedWriter(new FileWriter(outputPrefix + "_" + strategyPrefix + "_"
        + LEAVE_OUT_NUM + ".csv"));

    for (String line : result) {
      bw.write(line + CR);
    }
    bw.close();

  }

}
