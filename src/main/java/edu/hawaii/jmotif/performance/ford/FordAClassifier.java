package edu.hawaii.jmotif.performance.ford;

import java.io.IOException;
import java.util.logging.ConsoleHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Logger;
import org.hackystat.utilities.logger.HackystatLogger;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.util.BriefFormatter;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class FordAClassifier extends UCRGenericClassifier {

  private static final String outputPrefix = "fordA_stat_";

  // data locations
  private static final String TRAINING_DATA = "data/ford/Ford_A_TRAIN";
  private static final String TEST_DATA = "data/ford/Ford_A_TEST";

  // SAX parameters to use
  //
  private static final int PAA_MIN = 10;
  private static final int PAA_MAX = 150;
  private static final int PAA_INCREMENT = 5;

  private static final int ALPHABET_MIN = 3;
  private static final int ALPHABET_MAX = 15;
  private static final int ALPHABET_INCREMENT = 2;

  private static SAXCollectionStrategy strategy = SAXCollectionStrategy.EXACT;
  private static String strategyPrefix = "exact";

  private static Logger consoleLogger;

  private static String LOGGING_LEVEL = "FINE";

  // private static String LOGGING_LEVEL = "FINE";
  //
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

    // getting the command-line argument for a sliding window size
    //
    Integer windowSize = Integer.valueOf(args[0]);
    consoleLogger.fine("window size: " + windowSize);

    // configuring strategy
    //
    if (args.length > 1) {
      String strategyP = args[1];
      if ("NOREDUCTION".equalsIgnoreCase(strategyP)) {
        strategy = SAXCollectionStrategy.NOREDUCTION;
        strategyPrefix = "noreduction";
      }
      if ("CLASSIC".equalsIgnoreCase(strategyP)) {
        strategy = SAXCollectionStrategy.CLASSIC;
        strategyPrefix = "classic";
      }
      consoleLogger.fine("strategy: " + strategyPrefix);
    }

    // make up paa sizes
    int[] paa_sizes = makeArray(PAA_MIN, PAA_MAX, PAA_INCREMENT);

    // make up alphabet sizes
    int[] alphabet_sizes = makeArray(ALPHABET_MIN, ALPHABET_MAX, ALPHABET_INCREMENT);

    // make up output fname
    String outFname = outputPrefix + strategyPrefix + "_" + windowSize + ".csv";

    runClassificationExperiment(TRAINING_DATA, TEST_DATA, windowSize, paa_sizes, alphabet_sizes,
        strategy, outFname);
  }
}
