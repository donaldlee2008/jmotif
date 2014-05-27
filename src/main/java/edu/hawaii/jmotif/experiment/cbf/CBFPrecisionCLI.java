package edu.hawaii.jmotif.experiment.cbf;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.ConsoleHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Logger;
import org.hackystat.utilities.logger.HackystatLogger;
import edu.hawaii.jmotif.performance.UCRUtils;
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
public class CBFPrecisionCLI {

  private static final int WINDOW_SIZE = 35;
  private static final int PAA_SIZE = 4;
  private static final int ALPHABET_SIZE = 12;
  private static final SAXCollectionStrategy strategy = SAXCollectionStrategy.NOREDUCTION;

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

    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(args[0]);
    Map<String, List<double[]>> testData = UCRUtils.readUCRData(args[1]);

    double error = 0D;
    long jmotifStart = 0L;
    long jmotifFinish = 0L;

    for (int i = 0; i < 2; i++) {
      jmotifStart = System.currentTimeMillis();
      // classifying with JMotif
      //
      int testSampleSize = 0;
      int positiveTestCounter = 0;
      // building vectors
      //
      List<WordBag> bags = TextUtils.labeledSeries2WordBags(trainData, PAA_SIZE, ALPHABET_SIZE,
          WINDOW_SIZE, strategy);
      HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
      tfidf = TextUtils.normalizeToUnitVectors(tfidf);

      for (String label : tfidf.keySet()) {
        List<double[]> testD = testData.get(label);
        for (double[] series : testD) {
          positiveTestCounter = positiveTestCounter
              + TextUtils.classify(label, series, tfidf, PAA_SIZE, ALPHABET_SIZE, WINDOW_SIZE,
                  strategy);
          testSampleSize++;
        }
      }

      // accuracy and error
      double accuracy = (double) positiveTestCounter / (double) testSampleSize;
      error = 1.0d - accuracy;
      jmotifFinish = System.currentTimeMillis();
    }

    System.out.println("error: " + error + ", time " + String.valueOf(jmotifFinish - jmotifStart));

  }
}
