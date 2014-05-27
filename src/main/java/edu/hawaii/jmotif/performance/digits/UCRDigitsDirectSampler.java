package edu.hawaii.jmotif.performance.digits;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.TreeSet;
import java.util.concurrent.Callable;
import java.util.concurrent.CompletionService;
import java.util.concurrent.ExecutorCompletionService;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import org.hackystat.utilities.stacktrace.StackTrace;
import cc.mallet.util.Randoms;
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
public class UCRDigitsDirectSampler extends UCRGenericClassifier {

  // num of threads to use
  //
  private static final int THREADS_NUM = 3;

  // data
  //
  private static final String TRAINING_DATA = "data/digits/digits_reduced_400.csv";

  // output prefix
  //
  private static final String outputPrefix = "digits_direct";

  // SAX parameters to use
  //
  private static final int WINDOW_MIN = 170;
  private static final int WINDOW_MAX = 190;

  private static final int PAA_MIN = 14;
  private static final int PAA_MAX = 18;

  private static final int ALPHABET_MIN = 2;
  private static final int ALPHABET_MAX = 5;

  private static final int HOLD_OUT_NUM = 2;

  private static final int MAX_ITERATIONS = 3;

  private static List<String> globalResults = new ArrayList<String>();

  private UCRDigitsDirectSampler() {
    super();
  }

  /**
   * @param args
   * @throws Exception
   */
  @SuppressWarnings("unchecked")
  public static void main(String[] args) throws Exception {

    Map<String, List<double[]>> td = UCRUtils.readUCRData(TRAINING_DATA);
    consoleLogger.fine("reading file: " + TRAINING_DATA);
    consoleLogger.fine("trainData classes: " + td.size() + ", series length: "
        + td.entrySet().iterator().next().getValue().get(0).length);
    for (Entry<String, List<double[]>> e : td.entrySet()) {
      consoleLogger.fine(" training class: " + e.getKey() + " series: " + e.getValue().size());
    }

    consoleLogger.fine("re-sampling... ");
    Map<String, List<double[]>> fullData = resample(td, 8);
    consoleLogger.fine("trainData classes: " + fullData.size() + ", series length: "
        + fullData.entrySet().iterator().next().getValue().get(0).length);
    for (Entry<String, List<double[]>> e : fullData.entrySet()) {
      consoleLogger.fine(" training class: " + e.getKey() + " series: " + e.getValue().size());
    }

    for (int i = 1; i < 10; i++) {

      globalResults = new ArrayList<String>();

      String currentClass = String.valueOf(i);

      consoleLogger.fine(" separating class " + currentClass);

      Map<String, List<double[]>> trainData = new HashMap<String, List<double[]>>();

      trainData.put(currentClass, makeACopy(fullData.get(currentClass)));
      List<double[]> other = new ArrayList<double[]>();
      for (int k = 1; k < 10; k++) {
        if (!(currentClass.equalsIgnoreCase(String.valueOf(k)))) {
          other.addAll(resampleSubset(fullData.get(String.valueOf(k)), 3));
        }
      }
      trainData.put("other", other);

      consoleLogger.fine("After separation: trainData classes: " + trainData.size()
          + ", series length: " + trainData.entrySet().iterator().next().getValue().get(0).length);
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

      // create and submit the job for EXACT
      //
      ObjectiveFunction exactFunction = new UCRLOOCVErrorFunction();
      exactFunction.setStrategy(SAXCollectionStrategy.EXACT);
      PrintConsumer exactConsumer = new PrintConsumer(SAXCollectionStrategy.EXACT);
      exactFunction.setUpperBounds(parametersHighest);
      exactFunction.setLowerBounds(parametersLowest);
      exactFunction.setData(trainData, HOLD_OUT_NUM);
      DirectMethod exactMethod = new DirectMethod();
      exactMethod.addConsumer(exactConsumer);

      Solver exactSolver = new UCRSolver(MAX_ITERATIONS);
      exactSolver.init(exactFunction, exactMethod);

      completionService.submit((Callable<List<String>>) exactSolver);
      totalTaskCounter++;

      // create and submit the job for CLASSIC
      //
      ObjectiveFunction classicFunction = new UCRLOOCVErrorFunction();
      classicFunction.setStrategy(SAXCollectionStrategy.CLASSIC);
      PrintConsumer classicConsumer = new PrintConsumer(SAXCollectionStrategy.CLASSIC);
      classicFunction.setUpperBounds(parametersHighest);
      classicFunction.setLowerBounds(parametersLowest);
      classicFunction.setData(trainData, HOLD_OUT_NUM);
      DirectMethod classicMethod = new DirectMethod();
      classicMethod.addConsumer(classicConsumer);

      Solver classicSolver = new UCRSolver(MAX_ITERATIONS);
      classicSolver.init(classicFunction, classicMethod);

      completionService.submit((Callable<List<String>>) classicSolver);
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

      Collections.sort(globalResults, new Comparator<String>() {
        @Override
        public int compare(String arg0, String arg1) {
          String[] line1 = arg0.split(",");
          String[] line2 = arg0.split(",");
          return Double.valueOf(line1[line1.length - 1]).compareTo(
              Double.valueOf(line2[line2.length - 1]));
        }
      });

      System.out.println("Best result: " + globalResults.get(globalResults.size()-1));
      String paramsLine = globalResults.get(globalResults.size()-1);
      String[] split = paramsLine.split(",");
      String strategyKey = split[0];

    }
    BufferedWriter bw = new BufferedWriter(new FileWriter(outputPrefix + ".csv"));

    for (String line : globalResults) {
      bw.write(line + CR);
    }
    bw.close();

  }

  private static Collection<? extends double[]> resampleSubset(List<double[]> list, int resampleSize) {

    Randoms rnd = new Randoms();
    List<double[]> res = new ArrayList<double[]>();

    TreeSet<Integer> seen = new TreeSet<Integer>();
    for (int i = 0; i < resampleSize; i++) {
      Integer idx = 0;
      do {
        idx = (int) Math.floor(rnd.nextUniform(0., (double) list.size()));
      }
      while (seen.contains(idx));
      res.add(Arrays.copyOf(list.get(idx), list.get(idx).length));
      seen.add(idx);
    }

    return res;
  }

  private static List<double[]> makeACopy(List<double[]> list) {
    List<double[]> res = new ArrayList<double[]>();
    for (double[] s : list) {
      res.add(Arrays.copyOf(s, s.length));
    }
    return res;
  }

  private static Map<String, List<double[]>> resample(Map<String, List<double[]>> td,
      int resampleSize) {

    Randoms rnd = new Randoms();
    Map<String, List<double[]>> res = new HashMap<String, List<double[]>>();

    for (Entry<String, List<double[]>> e : td.entrySet()) {

      List<double[]> list = e.getValue();
      List<double[]> entry = new ArrayList<double[]>();

      TreeSet<Integer> seen = new TreeSet<Integer>();
      for (int i = 0; i < resampleSize; i++) {
        Integer idx = 0;
        do {
          idx = (int) Math.floor(rnd.nextUniform(0., (double) list.size()));
        }
        while (seen.contains(idx));
        entry.add(Arrays.copyOf(list.get(idx), list.get(idx).length));
        seen.add(idx);
      }

      res.put(e.getKey(), entry);
    }

    return res;
  }
}
