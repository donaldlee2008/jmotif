package edu.hawaii.jmotif.performance.cbf;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import cc.mallet.util.Randoms;
import edu.hawaii.jmotif.experiment.cbf.CBFGenerator;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class UCRcbfKNNDamaged extends UCRGenericClassifier {

  // num of threads to use
  //
  private static final int THREADS_NUM = 4;

  // data
  //
  private static final String TRAINING_DATA = "data/CBF/CBF_TRAIN";
  private static final String TEST_DATA = "data/CBF/CBF_TEST";

  // output prefix
  //
  private static final String outputPrefix = "cbf_loocv_generated_1";

  // SAX parameters to use
  //
  private static final int WINDOW_MIN = 20;
  private static final int WINDOW_MAX = 70;
  private static final int WINDOW_INCREMENT = 1;

  private static final int PAA_MIN = 4;
  private static final int PAA_MAX = 8;
  private static final int PAA_INCREMENT = 1;

  private static final int ALPHABET_MIN = 3;
  private static final int ALPHABET_MAX = 10;
  private static final int ALPHABET_INCREMENT = 1;

  // leave out parameters
  //
  private static final int LEAVE_OUT_NUM = 1;

  private static final int SERIES_LENGTH = 128;

  private static Randoms randoms;

  private UCRcbfKNNDamaged() {
    super();
  }

  /**
   * @param args
   * @throws Exception
   */
  public static void main(String[] args) throws Exception {

    randoms = new Randoms();

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

    // Map<String, List<double[]>> trainData = UCRUtils.readUCRData(TRAINING_DATA);

    Map<String, List<double[]>> trainData = generateSample(60);

    consoleLogger.fine("trainData classes: " + trainData.size() + ", series length: "
        + trainData.entrySet().iterator().next().getValue().get(0).length);
    for (Entry<String, List<double[]>> e : trainData.entrySet()) {
      consoleLogger.fine(" training class: " + e.getKey() + " series: " + e.getValue().size());
    }

    int totalTestSample = 0;
    // Map<String, List<double[]>> testData = UCRUtils.readUCRData(TEST_DATA);
    Map<String, List<double[]>> testData = generateSample(200);
    testData = damage(testData, 0.4, 0.167);

    consoleLogger.fine("testData classes: " + testData.size());
    for (Entry<String, List<double[]>> e : testData.entrySet()) {
      consoleLogger.fine(" test class: " + e.getKey() + " series: " + e.getValue().size());
      totalTestSample = totalTestSample + e.getValue().size();
    }

    // here is a loop over SAX parameters, strategy is fixed
    //
    for (int windowSize : window_sizes) {
      for (int paaSize : paa_sizes) {
        for (int alphabetSize : alphabet_sizes) {

          // make sure to brake if PAA greater than window
          if (windowSize < paaSize + 1) {
            continue;
          }

          // making training bags collection
          List<WordBag> bags = TextUtils.labeledSeries2WordBags(trainData, paaSize, alphabetSize,
              windowSize, SAXCollectionStrategy.NOREDUCTION);

          // getting TFIDF done
          HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);

          // System.out.println(TextUtils.bagsToTable(bags));

          // normalize vectors
          tfidf = TextUtils.normalizeToUnitVectors(tfidf);

          // System.out.println(TextUtils.tfidfToTable(tfidf));

          // classifying
          int testSampleSize = 0;
          int positiveTestCounter = 0;

          for (String label : tfidf.keySet()) {
            List<double[]> testD = testData.get(label);
            for (double[] series : testD) {
              positiveTestCounter = positiveTestCounter
                  + TextUtils.classify(label, series, tfidf, paaSize, alphabetSize, windowSize,
                      strategy);
              testSampleSize++;
            }
          }

          // accuracy and error
          double accuracy = (double) positiveTestCounter / (double) testSampleSize;
          double error = 1.0d - accuracy;

          // report results
          System.out.println(windowSize + COMMA + paaSize + COMMA + alphabetSize + COMMA + accuracy
              + COMMA + error);

        }
      }
    }

  }

  private static Map<String, List<double[]>> generateSample(int sampleSize) {

    Map<String, List<double[]>> res = new HashMap<String, List<double[]>>();

    // ticks
    int[] t = new int[SERIES_LENGTH];
    for (int i = 0; i < SERIES_LENGTH; i++) {
      t[i] = i;
    }

    // cylinder sample
    List<double[]> cylinders = new ArrayList<double[]>();
    for (int i = 0; i < sampleSize; i++) {
      cylinders.add(CBFGenerator.cylinder(t));
    }
    res.put("1", cylinders);

    // bell sample
    List<double[]> bells = new ArrayList<double[]>();
    for (int i = 0; i < sampleSize; i++) {
      bells.add(CBFGenerator.bell(t));
    }
    res.put("2", bells);

    // funnel sample
    List<double[]> funnels = new ArrayList<double[]>();
    for (int i = 0; i < sampleSize; i++) {
      funnels.add(CBFGenerator.funnel(t));
    }
    res.put("3", funnels);

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

}
