package edu.hawaii.jmotif.performance.wafer;

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
public class UCRwaferKNNThreaded extends UCRGenericClassifier {

  // data
  //
  private static final String TRAINING_DATA = "data/wafer/wafer_TRAIN";
  private static final String TEST_DATA = "data/wafer/wafer_TEST";

  // output prefix
  //
  private static final String outputPrefix = "wafer_loocv_threaded";
  
  // SAX parameters to use
  //
  private static final int WINDOW_MIN = 20;
  private static final int WINDOW_MAX = 40;
  private static final int WINDOW_INCREMENT = 2;

  private static final int PAA_MIN = 3;
  private static final int PAA_MAX = 18;
  private static final int PAA_INCREMENT = 3;

  private static final int ALPHABET_MIN = 3;
  private static final int ALPHABET_MAX = 15;
  private static final int ALPHABET_INCREMENT = 2;


  // leave out parameters
  //
  private static final int LEAVE_OUT_NUM = 1;
  private static final int THREADS_NUM = 1;

  private UCRwaferKNNThreaded() {
    super();
  }

  /**
   * @param args
   * @throws Exception
   */
  public static void main(String[] args) throws Exception {

    // configuring strategy
    //
    SAXCollectionStrategy strategy = SAXCollectionStrategy.NOREDUCTION;
    String strategyPrefix = "noreduction";
    if (args.length > 0) {
      String strategyP = args[0];
      if ("EXACT".equalsIgnoreCase(strategyP)) {
        strategy = SAXCollectionStrategy.EXACT;
        strategyPrefix = "exact";
      }
      if ("CLASSIC".equalsIgnoreCase(strategyP)) {
        strategy = SAXCollectionStrategy.CLASSIC;
        strategyPrefix = "classic";
      }
    }
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

    int totalTestSample = 0;
    Map<String, List<double[]>> testData = UCRUtils.readUCRData(TEST_DATA);
    consoleLogger.fine("testData classes: " + testData.size());
    for (Entry<String, List<double[]>> e : testData.entrySet()) {
      consoleLogger.fine(" test class: " + e.getKey() + " series: " + e.getValue().size());
      totalTestSample = totalTestSample + e.getValue().size();
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
