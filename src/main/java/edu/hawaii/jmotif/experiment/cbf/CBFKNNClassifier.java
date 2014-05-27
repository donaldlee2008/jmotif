package edu.hawaii.jmotif.experiment.cbf;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.timeseries.TSException;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class CBFKNNClassifier extends UCRGenericClassifier {

  private static final String CYLINDER_LABEL = "cylinder";
  private static final String BELL_LABEL = "bell";
  private static final String FUNNEL_LABEL = "funnel";

  /** The timeseries length. */
  private static final int SERIES_LENGTH = 128;

  /** The test set size. */
  private static final int TRAINING_SET_SIZE = 10;
  private static final int TEST_SAMPLE_SIZE = 300;

  // SAX parameters to use
  //
  private static final int WINDOW_SIZE = 44;
  private static final int PAA_SIZE = 10;
  private static final int ALPHABET_SIZE = 4;

  private static SAXCollectionStrategy strategy = SAXCollectionStrategy.EXACT;

  private static final String outputPrefix = "cbf_knn_exact_";

  public CBFKNNClassifier() {
    super();
  }

  /**
   * @param args
   * @throws TSException
   * @throws IndexOutOfBoundsException
   * @throws IOException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, TSException, IOException {

    // getting the command-line argument for a sliding window size
    //
    Integer windowSize = WINDOW_SIZE;
    String strategyP = "NOREDUCTION";
    if (args.length > 1) {
      windowSize = Integer.valueOf(args[0]);

      strategyP = args[1];
      if ("EXACT".equalsIgnoreCase(strategyP)) {
        strategy = SAXCollectionStrategy.EXACT;
      }
      if ("CLASSIC".equalsIgnoreCase(strategyP)) {
        strategy = SAXCollectionStrategy.CLASSIC;
      }
    }
    consoleLogger.fine("window size: " + windowSize);
    consoleLogger.fine("strategy: " + strategyP);

    // make up output fname
    String outFname = outputPrefix + windowSize + "_" + strategyP + ".csv";

    // making training and test collections
    Map<String, List<double[]>> trainData = new HashMap<String, List<double[]>>();
    Map<String, List<double[]>> testData = new HashMap<String, List<double[]>>();

    // ticks - i.e. time
    int[] t = new int[SERIES_LENGTH];
    for (int i = 0; i < SERIES_LENGTH; i++) {
      t[i] = i;
    }

    // cylinder sample
    List<double[]> cylinders = new ArrayList<double[]>();
    for (int i = 0; i < TRAINING_SET_SIZE + TEST_SAMPLE_SIZE; i++) {
      cylinders.add(CBFGenerator.cylinder(t));
    }
    trainData.put(CYLINDER_LABEL, extract(cylinders, 0, TRAINING_SET_SIZE));
    testData.put(CYLINDER_LABEL,
        extract(cylinders, TRAINING_SET_SIZE, TRAINING_SET_SIZE + TEST_SAMPLE_SIZE));

    // bell sample
    List<double[]> bells = new ArrayList<double[]>();
    for (int i = 0; i < TRAINING_SET_SIZE + TEST_SAMPLE_SIZE; i++) {
      bells.add(CBFGenerator.bell(t));
    }
    trainData.put(BELL_LABEL, extract(bells, 0, TRAINING_SET_SIZE));
    testData.put(BELL_LABEL,
        extract(bells, TRAINING_SET_SIZE, TRAINING_SET_SIZE + TEST_SAMPLE_SIZE));

    // funnel sample
    List<double[]> funnels = new ArrayList<double[]>();
    for (int i = 0; i < TRAINING_SET_SIZE + TEST_SAMPLE_SIZE; i++) {
      funnels.add(CBFGenerator.funnel(t));
    }
    trainData.put(FUNNEL_LABEL, extract(funnels, 0, TRAINING_SET_SIZE));
    testData.put(FUNNEL_LABEL,
        extract(funnels, TRAINING_SET_SIZE, TRAINING_SET_SIZE + TEST_SAMPLE_SIZE));

    runKNNExperiment(trainData, testData, windowSize, PAA_SIZE, ALPHABET_SIZE, strategy, outFname);

  }

  private static List<double[]> extract(List<double[]> cylinders, int start, int end) {
    List<double[]> res = new ArrayList<double[]>();
    for (int i = start; i < end; i++) {
      res.add(cylinders.get(i));
    }
    return res;
  }
}
