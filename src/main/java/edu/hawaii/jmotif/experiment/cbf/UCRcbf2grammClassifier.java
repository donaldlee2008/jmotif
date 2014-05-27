package edu.hawaii.jmotif.experiment.cbf;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.ConsoleHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Logger;
import org.hackystat.utilities.logger.HackystatLogger;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.text.Bigram;
import edu.hawaii.jmotif.text.BigramBag;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.util.BriefFormatter;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class UCRcbf2grammClassifier extends UCRGenericClassifier {

  private static final String outputPrefix = "2patterns_stat_";

  // classifier test parameters
  //
  /** The timeseries length. */
  private static final int SERIES_LENGTH = 128;

  /** The test set size. */
  private static int TRAINING_SET_SIZE = 1000;
  private static final int TEST_SAMPLE_SIZE = 100;

  // SAX parameters to use
  //
  private static final int PAA_MIN = 4;
  private static final int PAA_MAX = 4;
  private static final int PAA_INCREMENT = 1;

  private static final int ALPHABET_MIN = 3;
  private static final int ALPHABET_MAX = 3;
  private static final int ALPHABET_INCREMENT = 1;

  private static SAXCollectionStrategy strategy = SAXCollectionStrategy.EXACT;

  private static Logger consoleLogger;

  private static String LOGGING_LEVEL = "FINE";

  static {
    consoleLogger = HackystatLogger.getLogger("debug.console", "preseries");
    consoleLogger.setUseParentHandlers(false);
    for (Handler handler : consoleLogger.getHandlers()) {
      consoleLogger.removeHandler(handler);
    }
    ConsoleHandler handler = new ConsoleHandler();
    Formatter formatter = new BriefFormatter();
    handler.setFormatter(formatter);
    consoleLogger.addHandler(handler);
    HackystatLogger.setLoggingLevel(consoleLogger, LOGGING_LEVEL);
  }

  /**
   * @param args
   * @throws TSException
   * @throws IndexOutOfBoundsException
   * @throws IOException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, TSException, IOException {

    // making training and test collections
    Map<String, List<double[]>> trainData = new HashMap<String, List<double[]>>();
    Map<String, List<double[]>> testData = new HashMap<String, List<double[]>>();

    // ticks
    int[] t = new int[SERIES_LENGTH];
    for (int i = 0; i < SERIES_LENGTH; i++) {
      t[i] = i;
    }

    if (args.length > 0) {
      TRAINING_SET_SIZE = Integer.valueOf(args[0]);
    }

    BufferedWriter bw = new BufferedWriter(new FileWriter("output_"
        + String.valueOf(TRAINING_SET_SIZE) + ".csv"));

    // cylinder sample
    List<double[]> cylinders = new ArrayList<double[]>();
    for (int i = 0; i < TRAINING_SET_SIZE + TEST_SAMPLE_SIZE; i++) {
      cylinders.add(CBFGenerator.cylinder(t));
    }
    trainData.put("cylinder", extract(cylinders, 0, TRAINING_SET_SIZE));
    testData.put("cylinder",
        extract(cylinders, TRAINING_SET_SIZE, TRAINING_SET_SIZE + TEST_SAMPLE_SIZE));
    consoleLogger.info("All cylinders generated");

    // bell sample
    List<double[]> bells = new ArrayList<double[]>();
    for (int i = 0; i < TRAINING_SET_SIZE + TEST_SAMPLE_SIZE; i++) {
      bells.add(CBFGenerator.bell(t));
    }
    trainData.put("bell", extract(bells, 0, TRAINING_SET_SIZE));
    testData.put("bell", extract(bells, TRAINING_SET_SIZE, TRAINING_SET_SIZE + TEST_SAMPLE_SIZE));
    consoleLogger.info("All bells generated");

    // funnel sample
    List<double[]> funnels = new ArrayList<double[]>();
    for (int i = 0; i < TRAINING_SET_SIZE + TEST_SAMPLE_SIZE; i++) {
      funnels.add(CBFGenerator.funnel(t));
    }
    trainData.put("funnel", extract(funnels, 0, TRAINING_SET_SIZE));
    testData.put("funnel",
        extract(funnels, TRAINING_SET_SIZE, TRAINING_SET_SIZE + TEST_SAMPLE_SIZE));

    consoleLogger.info("All data generated");

    // make up paa sizes
    int[] paa_sizes = makeArray(PAA_MIN, PAA_MAX, PAA_INCREMENT);

    // make up alphabet sizes
    int[] alphabet_sizes = makeArray(ALPHABET_MIN, ALPHABET_MAX, ALPHABET_INCREMENT);

    int windowSize = 20;

    // make up output fname
    for (int paaSize : paa_sizes) {
      for (int alphabetSize : alphabet_sizes) {

        int[][] params = new int[1][4];
        params[0][0] = windowSize;
        params[0][1] = paaSize;
        params[0][2] = alphabetSize;
        params[0][3] = strategy.index();

        // making training bags collection
        List<BigramBag> bags = TextUtils.labeledSeries2BigramBags(trainData, params);

        HashMap<String, HashMap<Bigram, Double>> tfidf = TextUtils.computeTFIDF(bags);
        tfidf = TextUtils.normalizeBigramsToUnitVectors(tfidf);

        int totalTestSample = 0;
        int totalPositiveTests = 0;

        for (String label : tfidf.keySet()) {

          List<double[]> testD = testData.get(label);

          int positives = 0;
          for (double[] series : testD) {
            positives = positives
                + TextUtils.classifyBigrams(label, series, tfidf, params);
            totalTestSample++;
          }
          totalPositiveTests = totalPositiveTests + positives;

        }

        double accuracy = (double) totalPositiveTests / (double) totalTestSample;
        double error = 1.0d - accuracy;

        String str = paaSize + "," + alphabetSize + "," + windowSize + "," + accuracy + "," + error;
        bw.write(str + "\n");
        System.out.println(str);
      }
    }
    bw.close();
  }

  private static List<double[]> extract(List<double[]> cylinders, int start, int end) {
    List<double[]> res = new ArrayList<double[]>();
    for (int i = start; i < end; i++) {
      res.add(cylinders.get(i));
    }
    return res;
  }
}
