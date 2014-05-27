package edu.hawaii.jmotif.performance.beef;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.Callable;
import java.util.concurrent.CompletionService;
import java.util.concurrent.ExecutorCompletionService;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import org.hackystat.utilities.stacktrace.StackTrace;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.performance.UCRLOOCVErrorFunction;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.sampler.DirectMethod;
import edu.hawaii.jmotif.sampler.ObjectiveFunction;
import edu.hawaii.jmotif.sampler.PrintConsumer;
import edu.hawaii.jmotif.sampler.Solver;
import edu.hawaii.jmotif.sampler.UCRSolver;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class UCRBeefDirectSampler extends UCRGenericClassifier {

  // num of threads to use
  //
  private static final int THREADS_NUM = 2;

  // data
  //
  private static final String TRAINING_DATA = "data/Beef/Beef_TRAIN";

  // output prefix
  //
  private static final String outputPrefix = "beef_direct";

  // SAX parameters to use
  //
  private static final int WINDOW_MIN = 10;
  private static final int WINDOW_MAX = 470;

  private static final int PAA_MIN = 10;
  private static final int PAA_MAX = 120;

  private static final int ALPHABET_MIN = 3;
  private static final int ALPHABET_MAX = 16;

  private static final int HOLD_OUT_NUM = 1;

  private static final int MAX_ITERATIONS = 50;

  private static List<String> globalResults = new ArrayList<String>();

  private UCRBeefDirectSampler() {
    super();
  }

  /**
   * @param args
   * @throws Exception
   */
  @SuppressWarnings("unchecked")
  public static void main(String[] args) throws Exception {

    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(TRAINING_DATA);
    consoleLogger.fine("reading file: " + TRAINING_DATA);
    consoleLogger.fine("trainData classes: " + trainData.size() + ", series length: "
        + trainData.entrySet().iterator().next().getValue().get(0).length);
    for (Entry<String, List<double[]>> e : trainData.entrySet()) {
      consoleLogger.fine(" training class: " + e.getKey() + " series: " + e.getValue().size());
    }

    double[] parametersLowest = { Double.valueOf(WINDOW_MIN), Double.valueOf(PAA_MIN),
        Double.valueOf(ALPHABET_MIN) };
    double[] parametersHighest = { Double.valueOf(WINDOW_MAX), Double.valueOf(PAA_MAX),
        Double.valueOf(ALPHABET_MAX) };

    ExecutorService executorService = Executors.newFixedThreadPool(THREADS_NUM);
    CompletionService<List<String>> completionService = new ExecutorCompletionService<List<String>>(
        executorService);
    int totalTaskCounter = 0;

    // create and submit the job for NOREDUCTION
    //
    ObjectiveFunction noredFunction = new UCRLOOCVErrorFunction();
    noredFunction.setStrategy(SAXCollectionStrategy.NOREDUCTION);
    PrintConsumer noredConsumer = new PrintConsumer(SAXCollectionStrategy.NOREDUCTION);
    noredFunction.setUpperBounds(parametersHighest);
    noredFunction.setLowerBounds(parametersLowest);
    noredFunction.setData(trainData, HOLD_OUT_NUM);
    DirectMethod noredMethod = new DirectMethod();
    noredMethod.addConsumer(noredConsumer);

    Solver noredSolver = new UCRSolver(MAX_ITERATIONS);
    noredSolver.init(noredFunction, noredMethod);

    completionService.submit((Callable<List<String>>) noredSolver);
    totalTaskCounter++;
    
    
    // waiting for completion, shutdown pool disabling new tasks from being submitted
    executorService.shutdown();
    consoleLogger.info("Submitted " + totalTaskCounter + " jobs, shutting down the pool");

    // waiting for jobs to finish
    //
    //
    try {

      while (totalTaskCounter > 0) {
        //
        // poll with a wait up to FOUR hours
        Future<List<String>> finished = completionService.poll(128, TimeUnit.HOURS);
        if (null == finished) {
          // something went wrong - break from here
          System.err.println("Breaking POLL loop after 128 HOURS of waiting...");
          break;
        }
        else {
          List<String> res = finished.get();
          globalResults.addAll(res);
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

    BufferedWriter bw = new BufferedWriter(new FileWriter(outputPrefix + ".csv"));

    for (String line : globalResults) {
      bw.write(line + CR);
    }
    bw.close();

  }
}
