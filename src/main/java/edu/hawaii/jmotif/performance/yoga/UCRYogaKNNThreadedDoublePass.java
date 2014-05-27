package edu.hawaii.jmotif.performance.yoga;

import java.io.BufferedWriter;
import java.io.FileWriter;
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
import org.hackystat.utilities.stacktrace.StackTrace;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.performance.UCRKNNloocvDoublePassJob;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class UCRYogaKNNThreadedDoublePass extends UCRGenericClassifier {

  // num of threads to use
  //
  private static final int THREADS_NUM = 16;

  // data
  //
  private static final String TRAINING_DATA = "data/Yoga/yoga_TRAIN";
  private static final String TEST_DATA = "data/Yoga/yoga_TEST";

  // output prefix
  //
  private static final String outputPrefix = "yoga_loocv_ppt2";

  // SAX parameters to use
  //
  private static final int WINDOW_MIN = 20;
  private static final int WINDOW_MAX = 400;
  private static final int WINDOW_INCREMENT = 15;

  private static final int PAA_MIN = 5;
  private static final int PAA_MAX = 20;
  private static final int PAA_INCREMENT = 2;

  private static final int ALPHABET_MIN = 2;
  private static final int ALPHABET_MAX = 20;
  private static final int ALPHABET_INCREMENT = 2;

  // leave out parameters
  //
  private static final int LEAVE_OUT_NUM = 2;

  private UCRYogaKNNThreadedDoublePass() {
    super();
  }

  /**
   * @param args
   * @throws Exception
   */
  public static void main(String[] args) throws Exception {

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
    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(TRAINING_DATA);

    consoleLogger.fine("trainData classes: " + trainData.size() + ", series length: "
        + trainData.entrySet().iterator().next().getValue().get(0).length);
    for (Entry<String, List<double[]>> e : trainData.entrySet()) {
      consoleLogger.fine(" training class: " + e.getKey() + " series: " + e.getValue().size());
    }

    int totalTestSample = 0;
    Map<String, List<double[]>> testData = UCRUtils.readUCRData(TEST_DATA);
    consoleLogger.fine("testData classes: " + testData.size());
    for (Entry<String, List<double[]>> e : testData.entrySet()) {
      consoleLogger.fine(" test class: " + e.getKey() + " series: " + e.getValue().size());
      totalTestSample = totalTestSample + e.getValue().size();
    }

    int[][] params = new int[1][4];
    params[0][0] = 70;
    params[0][1] = 15;
    params[0][2] = 15;
    params[0][3] = SAXCollectionStrategy.NOREDUCTION.index();

    List<String> result = trainKNNFoldJMotifThreadedDoublePass(THREADS_NUM, window_sizes, paa_sizes,
        alphabet_sizes, strategy, params, trainData, LEAVE_OUT_NUM);

    BufferedWriter bw = new BufferedWriter(new FileWriter(outputPrefix + "_" + strategyPrefix + "_"
        + LEAVE_OUT_NUM + ".csv"));

    for (String line : result) {
      bw.write(line + CR);
    }
    bw.close();

  }

  private static List<String> trainKNNFoldJMotifThreadedDoublePass(int threadsNum, int[] window_sizes,
      int[] paa_sizes, int[] alphabet_sizes, SAXCollectionStrategy strategy, int[][] params,
      Map<String, List<double[]>> trainData, int leaveOutNum) {
    // make a result map
    //
    // here keys are parameters like window _ PAA _ Alphabet
    //
    //
    List<String> results = new ArrayList<String>();

    // create thread pool for processing these users
    //
    ExecutorService executorService = Executors.newFixedThreadPool(threadsNum);
    CompletionService<String> completionService = new ExecutorCompletionService<String>(
        executorService);
    int totalTaskCounter = 0;

    // here is a loop over SAX parameters, strategy is fixed
    //
    for (int windowSize : window_sizes) {
      for (int paaSize : paa_sizes) {
        for (int alphabetSize : alphabet_sizes) {

          // make sure to brake if PAA greater than window
          if (windowSize < paaSize + 1) {
            continue;
          }

          // create and submit the job
          final UCRKNNloocvDoublePassJob job = new UCRKNNloocvDoublePassJob(trainData, params,
              windowSize, paaSize, alphabetSize, strategy);

          completionService.submit(job);
          totalTaskCounter++;

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
        Future<String> finished = completionService.poll(96, TimeUnit.HOURS);
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

    return results;

  }

}
