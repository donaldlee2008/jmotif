package edu.hawaii.jmotif.experiment.cbf;

import java.io.IOException;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.logging.ConsoleHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Logger;
import org.hackystat.utilities.logger.HackystatLogger;
import edu.hawaii.jmotif.distance.EuclideanDistance;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.util.BriefFormatter;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class CBFKNNEuclideanClassifier {

  // various variables

  // classifier test parameters
  //
  /** The timeseries length. */
  private static final int SERIES_LENGTH = 128;

  /** The test set size. */
  private static final int TEST_SAMPLE_SIZE = 300;

  private static Logger consoleLogger;

  private static String LOGGING_LEVEL = "FINE";

  // uncoment that to remove early abandoning warning
  //
  // private static String LOGGING_LEVEL = "FINE";

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

    // ticks - i.e. time
    int[] t = new int[SERIES_LENGTH];
    for (int i = 0; i < SERIES_LENGTH; i++) {
      t[i] = i;
    }

    int TRAINING_SET_SIZE = Integer.valueOf(args[0]);

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

    // ################ begin classification
    //
    int totalPositiveTests = 0;
    int totalTestSample = TEST_SAMPLE_SIZE * 3;

    int queryCounter = 0;
    NumberFormat df = new DecimalFormat("0.00");

    // #### here we iterate over all TEST series, class by class, series by series
    //
    for (Entry<String, List<double[]>> querySet : testData.entrySet()) {
      for (double[] querySeries : querySet.getValue()) {

        consoleLogger.fine("classifying query " + queryCounter + " of class " + querySet.getKey());

        // this holds the closest neighbor out of all training data with its class
        //
        double bestDistance = Double.MAX_VALUE;
        String bestClass = "";

        // #### here we iterate over all TRAIN series, class by class, series by series
        //
        for (Entry<String, List<double[]>> referenceSet : trainData.entrySet()) {
          for (double[] referenceSeries : referenceSet.getValue()) {

            // this computes the Euclidean distance.
            // earlyAbandonedDistance implementation abandons full distance computation
            // if current value is above the best known
            //
            Double distance = EuclideanDistance.earlyAbandonedDistance(querySeries,
                referenceSeries, bestDistance);
            // Double distance = EuclideanDistance.earlyAbandonedDistance(
            // TSUtils.zNormalize(querySeries), TSUtils.zNormalize(referenceSeries), bestDistance);

            if (null != distance && distance.doubleValue() < bestDistance) {
              bestDistance = distance.doubleValue();
              bestClass = referenceSet.getKey();
              consoleLogger.fine(" + closest class: " + bestClass + " distance: " + bestDistance);
            }
            else {
              // consoleLogger.fine(" - abandoned search for class: " + referenceSet.getKey()
              // + ", distance: " + EuclideanDistance.distance(querySeries, referenceSeries));

              // consoleLogger.fine(" - abandoned search for class: "
              // + referenceSet.getKey()
              // + ", distance: "
              // + EuclideanDistance.distance(TSUtils.zNormalize(querySeries),
              // TSUtils.zNormalize(referenceSeries)));

            }

          }
        }

        if (bestClass.equalsIgnoreCase(querySet.getKey())) {
          totalPositiveTests++;
        }

        queryCounter++;
      }
    }

    double accuracy = (double) totalPositiveTests / (double) totalTestSample;
    double error = 1.0d - accuracy;

    System.out.println(accuracy + "," + error + "\n");

  }

  private static List<double[]> extract(List<double[]> cylinders, int start, int end) {
    List<double[]> res = new ArrayList<double[]>();
    for (int i = start; i < end; i++) {
      res.add(cylinders.get(i));
    }
    return res;
  }
}
