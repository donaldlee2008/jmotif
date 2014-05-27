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
import edu.hawaii.jmotif.sax.SAXFactory;
import edu.hawaii.jmotif.sax.alphabet.Alphabet;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;
import edu.hawaii.jmotif.util.BriefFormatter;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class CBFPrecisionExperiment {

  private static final int[] SAMPLING_POINTS = { 10, 50, 125, 250, 500, 750, 1000 };

  private static final int TEST_SET_SIZE = 10000;

  private static final int REPEATS = 10;

  private static int WINDOW_SIZE = 60;
  private static int PAA_SIZE = 7;
  private static int ALPHABET_SIZE = 7;
  private static SAXCollectionStrategy strategy = SAXCollectionStrategy.NOREDUCTION;

  private static Logger consoleLogger;

  private static String LOGGING_LEVEL = "FINE";

  private static Randoms randoms;

  private static final Alphabet a = new NormalAlphabet();

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

    WINDOW_SIZE = Integer.valueOf(args[0]);
    PAA_SIZE = Integer.valueOf(args[1]);
    ALPHABET_SIZE = Integer.valueOf(args[2]);

    if ("exact".equalsIgnoreCase(args[3])) {
      strategy = SAXCollectionStrategy.EXACT;
    }
    else if ("classic".equalsIgnoreCase(args[3])) {
      strategy = SAXCollectionStrategy.CLASSIC;
    }

//    int DAMAGE_PERCENTAGE = Integer.valueOf(args[4]);
//    int NOISE_STDEV = Integer.valueOf(args[5]);

    String msg = "W: " + WINDOW_SIZE + ", PAA: " + PAA_SIZE + ", A: " + ALPHABET_SIZE + ", S: "
        + getStrategyPrefix(strategy);
//        + ", Damage percentage: " + DAMAGE_PERCENTAGE
//        + ", Noise stdDev: " + NOISE_STDEV;
    consoleLogger.info(msg);
    System.out.println("# " + msg);
    // Map<String, List<double[]>> tData = getDataSet(100);
    // tData = damage(tData, 0.30, 0.30D);
    // saveData("cbf_damaged", tData);
    // System.exit(0);

    for (int rep = 0; rep < REPEATS; rep++) {

      // saveData("cbf_performance_test", testData);

      for (int currentStep : SAMPLING_POINTS) {

        // making training and test collections
        Map<String, List<double[]>> trainData = getDataSet(currentStep);

        // saveData("cbf_train" + String.valueOf(currentStep), trainData);

        Map<String, List<double[]>> testData = getDataSet(TEST_SET_SIZE);
//        testData = damage(testData, Integer.valueOf(DAMAGE_PERCENTAGE).doubleValue() / 100D,
//            Integer.valueOf(NOISE_STDEV).doubleValue());

        // classifying with JMotif
        //
        int testSampleSize = 0;
        int positiveTestCounter = 0;

        long jmotifStart = System.currentTimeMillis();
        // building vectors
        //
        List<WordBag> bags = labeledSeries2WordBags(trainData, PAA_SIZE, ALPHABET_SIZE,
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

                Double distance = EuclideanDistance.distance(querySeries, referenceSeries);

                // this computes the Euclidean distance.
                // earlyAbandonedDistance implementation abandons full distance computation
                // if current value is above the best known
                //
//                Double distance = EuclideanDistance.earlyAbandonedDistance(querySeries,
//                    referenceSeries, bestDistance);

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

        double euclideanAccuracy = (double) euclideanPositiveTests / (double) euclideanQueryCounter;
        double euclideanError = 1.0d - euclideanAccuracy;

        System.out.println(Integer.valueOf(currentStep).doubleValue() + "," + error + ","
            + euclideanError + "," + (jmotifFinish - jmotifStart) + ","
            + (jmotifTFIDF - jmotifStart) + "," + (euclideanFinish - euclideanStart));

        // saveData("cbf_performance_test_damaged" + String.valueOf(currentStep), testData);

      }

    }
  }

  private static List<WordBag> labeledSeries2WordBags(Map<String, List<double[]>> data,
      int paaSize, int alphabetSize, int windowSize, SAXCollectionStrategy strategy)
      throws IndexOutOfBoundsException, TSException {

    // make a map of resulting bags
    Map<String, WordBag> preRes = new HashMap<String, WordBag>();

    // process series one by one building word bags
    for (Entry<String, List<double[]>> e : data.entrySet()) {

      String classLabel = e.getKey();
      WordBag bag = new WordBag(classLabel);

      for (double[] series : e.getValue()) {
        //
        // series to words
        String oldStr = "";
        for (int i = 0; i <= series.length - windowSize; i++) {

          double[] paa = TSUtils.optimizedPaa(TSUtils.zNormalize(TSUtils.subseries(series, i, windowSize)),
              paaSize);

          char[] sax = TSUtils.ts2String(paa, a.getCuts(alphabetSize));

          if (SAXCollectionStrategy.CLASSIC.equals(strategy)) {
            if (oldStr.length() > 0 && SAXFactory.strDistance(sax, oldStr.toCharArray()) == 0) {
              continue;
            }
          }
          else if (SAXCollectionStrategy.EXACT.equals(strategy)) {
            if (oldStr.equalsIgnoreCase(String.valueOf(sax))) {
              continue;
            }
          }

          oldStr = String.valueOf(sax);

          bag.addWord(String.valueOf(sax));
        }
        //
        //
      }

      preRes.put(classLabel, bag);
    }

    List<WordBag> res = new ArrayList<WordBag>();
    res.addAll(preRes.values());
    return res;
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
