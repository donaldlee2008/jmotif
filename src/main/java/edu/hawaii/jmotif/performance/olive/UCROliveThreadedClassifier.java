package edu.hawaii.jmotif.performance.olive;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.CompletionService;
import java.util.concurrent.ExecutorCompletionService;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.logging.ConsoleHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Logger;
import org.hackystat.utilities.logger.HackystatLogger;
import org.hackystat.utilities.stacktrace.StackTrace;
import edu.hawaii.jmotif.performance.UCRClassificationSeriesJob;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.util.BriefFormatter;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class UCROliveThreadedClassifier extends UCRGenericClassifier {

  private static final String outputPrefix = "olive";
  private static final int MAX_THREADS = 19;

  // data locations
  private static final String TRAINING_DATA = "data/OliveOil/OliveOil_TRAIN";
  private static final String TEST_DATA = "data/OliveOil/OliveOil_TEST";

  // SAX parameters to use
  //
  private static final int WINDOW_MIN = 200;
  private static final int WINDOW_MAX = 400;
  private static final int WINDOW_INCREMENT = 10;

  private static final int PAA_MIN = 30;
  private static final int PAA_MAX = 80;
  private static final int PAA_INCREMENT = 2;

  private static final int ALPHABET_MIN = 2;
  private static final int ALPHABET_MAX = 10;
  private static final int ALPHABET_INCREMENT = 1;

  private static final SAXCollectionStrategy[] strategies = { SAXCollectionStrategy.CLASSIC,
      SAXCollectionStrategy.EXACT, SAXCollectionStrategy.NOREDUCTION };

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

    // reading training and test collections
    //
    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(TRAINING_DATA);
    consoleLogger.fine("trainData classes: " + trainData.size() + ", series length: "
        + trainData.entrySet().iterator().next().getValue().get(0).length);
    for (Entry<String, List<double[]>> e : trainData.entrySet()) {
      consoleLogger.fine(" training class: " + e.getKey() + " series: " + e.getValue().size());
    }

    Map<String, List<double[]>> testData = UCRUtils.readUCRData(TEST_DATA);
    consoleLogger.fine("testData classes: " + testData.size());
    for (Entry<String, List<double[]>> e : testData.entrySet()) {
      consoleLogger.fine(" test class: " + e.getKey() + " series: " + e.getValue().size());
    }

    // make up paa sizes
    int[] paa_sizes = makeArray(PAA_MIN, PAA_MAX, PAA_INCREMENT);

    // make up alphabet sizes
    int[] alphabet_sizes = makeArray(ALPHABET_MIN, ALPHABET_MAX, ALPHABET_INCREMENT);

    // make up alphabet sizes
    int[] window_sizes = makeArray(WINDOW_MIN, WINDOW_MAX, WINDOW_INCREMENT);

    // create thread pool for processing these users
    //
    ExecutorService executorService = Executors.newFixedThreadPool(MAX_THREADS);
    CompletionService<String> completionService = new ExecutorCompletionService<String>(
        executorService);

    // process these things
    //
    List<String> results = new ArrayList<String>();
    int totalTaskCounter = 0;
    for (int windowSize : window_sizes) {
      for (int paaSize : paa_sizes) {

        if (windowSize < paaSize + 1) {
          continue;
        }

        for (int alphabetSize : alphabet_sizes) {
          for (SAXCollectionStrategy strategy : strategies) {

            // create and submit the job
            final UCRClassificationSeriesJob job = new UCRClassificationSeriesJob(strategy,
                windowSize, paaSize, alphabetSize, testData, trainData);

            completionService.submit(job);
            totalTaskCounter++;

          }
        }
      }
    }

    // waiting for completion, shutdown pool disabling new tasks from being submitted
    executorService.shutdown();
    consoleLogger.info("Submitted " + totalTaskCounter + " jobs, shutting down the pool");

    try {

      while (totalTaskCounter > 0) {
        //
        // poll with a wait up to FOUR hours
        Future<String> finished = completionService.poll(48, TimeUnit.HOURS);
        if (null == finished) {
          // something went wrong - break from here
          System.err.println("Breaking POLL loop after 48 HOURS of waiting...");
          break;
        }
        else {
          String res = finished.get();
          if (!(res.startsWith("ok_"))) {
            System.err.println("Exception caught: " + finished.get());
            break;
          }
          else {
            String record = res.substring(3);
            consoleLogger.info(record);
            results.add(record);
          }
          totalTaskCounter--;
        }
      }
      consoleLogger.info("All jobs completed.");

    }
    catch (Exception e) {
      System.err.println("Error while waiting results: " + StackTrace.toString(e));
    }
    finally {
      // wait at least 1 more hour before terminate and fail
      try {
        if (!executorService.awaitTermination(1, TimeUnit.HOURS)) {
          executorService.shutdownNow(); // Cancel currently executing tasks
          if (!executorService.awaitTermination(30, TimeUnit.MINUTES))
            System.err.println("Pool did not terminate... FATAL ERROR");
        }
      }
      catch (InterruptedException ie) {
        System.err.println("Error while waiting interrupting: " + StackTrace.toString(ie));
        // (Re-)Cancel if current thread also interrupted
        executorService.shutdownNow();
        // Preserve interrupt status
        Thread.currentThread().interrupt();
      }

    }

    BufferedWriter bw = new BufferedWriter(new FileWriter(outputPrefix + "_threaded_run.csv"));

    for (String line : results) {
      bw.write(line + CR);
    }
    bw.close();

  }

}
