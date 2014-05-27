package edu.hawaii.jmotif.experiment.cbf;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.logging.ConsoleHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Logger;
import org.hackystat.utilities.logger.HackystatLogger;
import cc.mallet.util.Randoms;
import edu.hawaii.jmotif.distance.EuclideanDistance;
import edu.hawaii.jmotif.sax.alphabet.Alphabet;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.util.BriefFormatter;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class CBFProgressivePrecisionExperiment {

  protected final static int CLASSIC = 0;
  protected final static int EXACT = 1;
  protected final static int NOREDUCTION = 2;

  private static final double[] NOISE_SAMPLING_POINTS = { 0.0, 0.05, 0.1, 0.15, 0.20, 0.25, 0.30,
      0.35, 0.4, 0.45, 0.5 };

  private static final int[] TRAIN_SAMPLE_SIZE = { 5, 10, 25, 50, 75, 100, 150, 250, 500, 1000 };

  // private static final double[] NOISE_SAMPLING_POINTS = { 0.4, 0.4, 0.4, 0.4, 0.4, 0.4,
  // 0.4 };

  private static final int[][] SAX_PARAMS_POINTS = { { 60, 7, 7, NOREDUCTION },
      { 55, 6, 4, NOREDUCTION }, { 50, 7, 7, NOREDUCTION }, { 50, 7, 7, NOREDUCTION },
      { 45, 6, 6, NOREDUCTION }, { 45, 6, 6, NOREDUCTION }, { 40, 6, 5, NOREDUCTION },
      { 30, 6, 4, NOREDUCTION }, { 30, 6, 4, NOREDUCTION }, { 24, 8, 4, NOREDUCTION },
      { 24, 8, 5, NOREDUCTION } };

  // { 30, 6, 4, NOREDUCTION },
  // { 32, 6, 4, NOREDUCTION },
  // { 36, 6, 6, NOREDUCTION },
  // { 38, 7, 5, NOREDUCTION },
  // { 40, 7, 6, NOREDUCTION },
  // { 44, 8, 6, NOREDUCTION },
  // { 50, 8, 6, NOREDUCTION }, };

  private static final int TEST_SET_SIZE = 10000;

  private static final int REPEATS = 10;

  private static Logger consoleLogger;

  private static String LOGGING_LEVEL = "FINE";

  private static Randoms randoms;

  private static final Alphabet a = new NormalAlphabet();
  private static final String COMMA = ",";
  private static final double NOISE_STDEV = 0.167;

  static {

    randoms = new Randoms();

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

    for (int rep = 0; rep < REPEATS; rep++) {

      for (int tSize : TRAIN_SAMPLE_SIZE) {

        Map<String, List<double[]>> trainData = getDataSet(tSize);

        for (int i = 0; i < NOISE_SAMPLING_POINTS.length; i++) {

          double lossPercentage = NOISE_SAMPLING_POINTS[i];
          double lossStDev = NOISE_STDEV;

          int[] params = SAX_PARAMS_POINTS[i];

          String msg = toLogStr(params, lossPercentage, lossStDev);
          consoleLogger.info(msg);

          Map<String, List<double[]>> testData = getDataSet(TEST_SET_SIZE);

          testData = damage(testData, lossPercentage, lossStDev);

          // classifying with JMotif
          //
          int testSampleSize = 0;
          int positiveTestCounter = 0;

          long jmotifStart = System.currentTimeMillis();

          // building vectors
          //
          // converting back from easy encoding
          int WINDOW_SIZE = params[0];
          int PAA_SIZE = params[1];
          int ALPHABET_SIZE = params[2];
          SAXCollectionStrategy strategy = SAXCollectionStrategy.CLASSIC;
          if (EXACT == params[3]) {
            strategy = SAXCollectionStrategy.EXACT;
          }
          else if (NOREDUCTION == params[3]) {
            strategy = SAXCollectionStrategy.NOREDUCTION;
          }

          // making training bags collection
          List<WordBag> bags = TextUtils.labeledSeries2WordBags(trainData, PAA_SIZE, ALPHABET_SIZE,
              WINDOW_SIZE, strategy);

          HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
          tfidf = TextUtils.normalizeToUnitVectors(tfidf);

          long jmotifTFIDF = System.currentTimeMillis();

          for (String label : tfidf.keySet()) {
            List<double[]> testD = testData.get(label);
            for (double[] series : testD) {
              positiveTestCounter = positiveTestCounter
                  + TextUtils.classify(label, series, tfidf, PAA_SIZE, ALPHABET_SIZE, WINDOW_SIZE,
                      strategy);
              testSampleSize++;
            }
          }
          long jmotifFinish = System.currentTimeMillis();

          // accuracy and error
          double accuracy = (double) positiveTestCounter / (double) testSampleSize;
          double error = 1.0d - accuracy;

          // euclidean 1-NN
          // #### here we iterate over all TEST series, class by class, series by series
          //
          int euclideanPositiveTests = 0;
          int euclideanQueryCounter = 0;
          long euclideanStart = System.currentTimeMillis();
          for (Entry<String, List<double[]>> querySet : testData.entrySet()) {
            for (double[] querySeries : querySet.getValue()) {

              // this holds the closest neighbor out of all training data with its class
              double bestDistance = Double.MAX_VALUE;
              String bestClass = "";

              // #### here we iterate over all TRAIN series, class by class, series by series
              //
              for (Entry<String, List<double[]>> referenceSet : trainData.entrySet()) {
                for (double[] referenceSeries : referenceSet.getValue()) {

                  // Double distance = EuclideanDistance.distance(querySeries, referenceSeries);

                  // this computes the Euclidean distance.
                  // earlyAbandonedDistance implementation abandons full distance computation
                  // if current value is above the best known
                  //
                  Double distance = EuclideanDistance.earlyAbandonedDistance(querySeries,
                      referenceSeries, bestDistance);

                  if (null != distance && distance.doubleValue() < bestDistance) {
                    bestDistance = distance.doubleValue();
                    bestClass = referenceSet.getKey();
                  }

                }
              }

              if (bestClass.equalsIgnoreCase(querySet.getKey())) {
                euclideanPositiveTests++;
              }

              euclideanQueryCounter++;
            }
          }
          long euclideanFinish = System.currentTimeMillis();

          double euclideanAccuracy = (double) euclideanPositiveTests
              / (double) euclideanQueryCounter;
          double euclideanError = 1.0d - euclideanAccuracy;

          System.out.println(msg + COMMA + tSize + COMMA + error + COMMA + euclideanError
              + COMMA + (jmotifFinish - jmotifStart) + COMMA + (jmotifTFIDF - jmotifStart) + COMMA
              + (euclideanFinish - euclideanStart));

          // System.out.println(msg + COMMA + lossPercentage + COMMA + error + COMMA +
          // euclideanError
          // + COMMA + (jmotifFinish - jmotifStart) + COMMA + (jmotifTFIDF - jmotifStart) + COMMA
          // + (euclideanFinish - euclideanStart));

          // saveData("cbf_performance_test_damaged" + String.valueOf(currentStep), testData);

        }
      }
    }
  }

  private static String toLogStr(int[] p, double lossPercentage, double lossStDev) {
    StringBuffer sb = new StringBuffer();
    if (SAXCollectionStrategy.CLASSIC.index() == p[3]) {
      sb.append("CLASSIC,");
    }
    else if (SAXCollectionStrategy.EXACT.index() == p[3]) {
      sb.append("EXACT,");
    }
    else if (SAXCollectionStrategy.NOREDUCTION.index() == p[3]) {
      sb.append("NOREDUCTION,");
    }
    sb.append(p[0]).append(COMMA);
    sb.append(p[1]).append(COMMA);
    sb.append(p[2]).append(COMMA);
    sb.append(lossPercentage).append(COMMA);
    sb.append(lossStDev);

    return sb.toString();
  }

  private static Map<String, List<double[]>> damage(Map<String, List<double[]>> trainData,
      double damagedIntervalLength, double noiseStandardDeviation) {
    Map<String, List<double[]>> res = new HashMap<String, List<double[]>>();
    for (Entry<String, List<double[]>> referenceSet : trainData.entrySet()) {
      List<double[]> newData = new ArrayList<double[]>();
      int seriesCounter = 0;
      for (double[] referenceSeries : referenceSet.getValue()) {
        // if (seriesCounter > 3 && seriesCounter < 5) {
        // System.out.println(referenceSet.getKey() + " = " + Arrays.toString(referenceSeries));
        // }
        int noiseStart = Double.valueOf(
            Math.floor(randoms.nextUniform(0D, 128D * (1 - damagedIntervalLength)))).intValue();
        int noiseEnd = noiseStart + Double.valueOf(128D * damagedIntervalLength).intValue();
        for (int i = noiseStart; i < noiseEnd; i++) {
          referenceSeries[i] = randoms.nextGaussian(0, noiseStandardDeviation);
        }
        // if (seriesCounter > 3 && seriesCounter < 5) {
        // System.out.println(referenceSet.getKey() + "<-" + Arrays.toString(referenceSeries));
        // }
        newData.add(referenceSeries);
        seriesCounter++;
      }
      res.put(referenceSet.getKey(), newData);
    }
    return res;
  }

  private static void saveData(String fileName, Map<String, List<double[]>> data)
      throws IOException {
    BufferedWriter wr = new BufferedWriter(new FileWriter(new File(fileName)));
    for (Entry<String, List<double[]>> cClass : data.entrySet()) {
      for (double[] series : cClass.getValue()) {
        wr.write(String.valueOf(cClass.getKey()) + " "
            + Arrays.toString(series).replace("[", "").replace(", ", " ").replace("]", "\n"));
      }
    }
    wr.close();
  }

  private static Map<String, List<double[]>> getDataSet(int size) {

    Map<String, List<double[]>> res = new HashMap<String, List<double[]>>();

    // ticks - i.e. time
    int[] t = new int[128];
    for (int i = 0; i < 128; i++) {
      t[i] = i;
    }

    // cylinder sample
    List<double[]> cylinders = new ArrayList<double[]>();
    for (int i = 0; i < size; i++) {
      cylinders.add(CBFGenerator.cylinder(t));
    }
    res.put("0", cylinders);

    // bell sample
    List<double[]> bells = new ArrayList<double[]>();
    for (int i = 0; i < size; i++) {
      bells.add(CBFGenerator.bell(t));
    }
    res.put("1", bells);

    // funnel sample
    List<double[]> funnels = new ArrayList<double[]>();
    for (int i = 0; i < size; i++) {
      funnels.add(CBFGenerator.funnel(t));
    }
    res.put("2", funnels);

    return res;
  }

  protected static String getStrategyPrefix(SAXCollectionStrategy strategy) {
    String strategyP = "noreduction";
    if (SAXCollectionStrategy.EXACT.equals(strategy)) {
      strategyP = "exact";
    }
    if (SAXCollectionStrategy.CLASSIC.equals(strategy)) {
      strategy = SAXCollectionStrategy.CLASSIC;
      strategyP = "classic";
    }
    return strategyP;
  }
}
