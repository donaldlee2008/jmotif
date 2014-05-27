package edu.hawaii.jmotif.experiment.cbf;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
public class CBFFitClassifier {

  // various variables

  // classifier test parameters
  //
  /** The timeseries length. */
  private static final int SERIES_LENGTH = 128;

  /** The test set size. */
  private static int TRAINING_SET_SIZE = 200;
  private static final int TEST_SAMPLE_SIZE = 1000;

  // SAX parameters to use
  //
  private static int[] PAA_SIZES = { 7 };
  private static int[] ALPHABET_SIZES = { 7 };
  private static int[] WINDOW_SIZES = { 40 };

  private static SAXCollectionStrategy strategy = SAXCollectionStrategy.EXACT;

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
    trainData.put("0", extract(cylinders, 0, TRAINING_SET_SIZE));
    testData.put("0", extract(cylinders, TRAINING_SET_SIZE, TRAINING_SET_SIZE + TEST_SAMPLE_SIZE));

    // bell sample
    List<double[]> bells = new ArrayList<double[]>();
    for (int i = 0; i < TRAINING_SET_SIZE + TEST_SAMPLE_SIZE; i++) {
      bells.add(CBFGenerator.bell(t));
    }
    trainData.put("1", extract(bells, 0, TRAINING_SET_SIZE));
    testData.put("1", extract(bells, TRAINING_SET_SIZE, TRAINING_SET_SIZE + TEST_SAMPLE_SIZE));

    // funnel sample
    List<double[]> funnels = new ArrayList<double[]>();
    for (int i = 0; i < TRAINING_SET_SIZE + TEST_SAMPLE_SIZE; i++) {
      funnels.add(CBFGenerator.funnel(t));
    }
    trainData.put("2", extract(funnels, 0, TRAINING_SET_SIZE));
    testData.put("2", extract(funnels, TRAINING_SET_SIZE, TRAINING_SET_SIZE + TEST_SAMPLE_SIZE));

    for (int paaSize : PAA_SIZES) {
      for (int alphabetSize : ALPHABET_SIZES) {
        for (int windowSize : WINDOW_SIZES) {

          if (windowSize < paaSize + 1) {
            continue;
          }

          // making training bags collection
          List<WordBag> bags = TextUtils.labeledSeries2WordBags(trainData, paaSize, alphabetSize,
              windowSize, strategy);

          HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
          tfidf = TextUtils.normalizeToUnitVectors(tfidf);

          int totalTestSample = 0;
          int totalPositiveTests = 0;

          for (String label : tfidf.keySet()) {

            List<double[]> testD = testData.get(label);

            int positives = 0;
            for (double[] series : testD) {
              positives = positives
                  + TextUtils.classify(label, series, tfidf, paaSize, alphabetSize, windowSize,
                      strategy);
              totalTestSample++;
            }
            totalPositiveTests = totalPositiveTests + positives;

          }

          double accuracy = (double) totalPositiveTests / (double) totalTestSample;
          double error = 1.0d - accuracy;

          bw.write(paaSize + "," + alphabetSize + ", " + windowSize + "," + accuracy + "," + error
              + "\n");
        }
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
