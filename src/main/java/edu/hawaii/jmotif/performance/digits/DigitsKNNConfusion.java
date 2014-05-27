package edu.hawaii.jmotif.performance.digits;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
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
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.timeseries.TSException;

/**
 * Helper-runner for test.
 * 
 * @author psenin
 * 
 */
public class DigitsKNNConfusion extends UCRGenericClassifier {

  // data locations
  //
  private static final String TRAINING_DATA = "data/digits/digits_reduced_400.csv";
  private static final String TEST_DATA = "data/digits/digits_train.txt";

  // SAX parameters to try
  //
  private static final int[][] params = { { 177, 16, 3, NOREDUCTION }, };
  private static final int threadsNum = 8;

  /**
   * Runnable.
   * 
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    // making training and test collections
    //
    Map<String, double[]> trainData = readTrainData(TRAINING_DATA);
    List<double[]> testData = readTestData(TEST_DATA);

    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(
        "data/digits/second_try_reduced400.csv")));
    bw.write("ImageId,Label\n");

    // iterate over parameters
    //
    for (int[] p : params) {

      int correct1 = 0;
      int correct2 = 0;

      // making training bags collection
      Map<String, WordBag> bags = buildBags(trainData, p);
      consoleLogger.info("Built all the bags");

      // create thread pool for processing these users
      //
      ExecutorService executorService = Executors.newFixedThreadPool(threadsNum);
      CompletionService<String> completionService = new ExecutorCompletionService<String>(
          executorService);
      int totalTaskCounter = 0;

      int seriesCounter = 1;
      for (double[] series : testData) {

        // create and submit the job
        final DigitsConfusionJob job = new DigitsConfusionJob(series, seriesCounter, bags, p);

        completionService.submit(job);
        totalTaskCounter++;

        seriesCounter++;
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
              String idx = res.substring(res.indexOf(":") + 2, res.indexOf(",", res.indexOf(":")));
              String predicted1 = res.substring(res.lastIndexOf(",") - 1, res.lastIndexOf(","));
              String predicted2 = res.substring(res.lastIndexOf(",") + 1);

              StringBuffer sb = new StringBuffer();
              if (predicted1.equalsIgnoreCase(String.valueOf((int) testData.get(Integer
                  .valueOf(idx) - 1)[0]))) {
                sb.append("ok");
                correct1++;
              }
              else {
                sb.append("not");
              }

              sb.append(",");

              if (predicted2.equalsIgnoreCase(String.valueOf((int) testData.get(Integer
                  .valueOf(idx) - 1)[0]))) {
                sb.append("ok");
                correct2++;
              }
              else {
                sb.append("not");
              }

              consoleLogger.info(res + " : " + idx + ", " + predicted1 + ", " + predicted2 + ", "
                  + sb.toString());
              bw.write(res + "\n");
            }
            totalTaskCounter--;

            if (totalTaskCounter % 1000 == 0) {
              consoleLogger.info("accuracy with voting: "
                  + ((double) correct1 / (double) (testData.size() - totalTaskCounter))
                  + ", accuracy NN: " + ((double) correct2)
                  / (double) (testData.size() - totalTaskCounter));
            }
          }
        }
        consoleLogger.info("All jobs completed.");
        consoleLogger.info("accuracy with voting: "
            + ((double) correct1 / (double) testData.size()) + ", accuracy NN: "
            + ((double) correct2) / (double) testData.size());

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

    }
    bw.close();

  }

  private static Map<String, WordBag> buildBags(Map<String, double[]> trainData, int[] params)
      throws IndexOutOfBoundsException, TSException {

    Map<String, WordBag> res = new HashMap<String, WordBag>();

    // create thread pool for processing these users
    //
    ExecutorService executorService = Executors.newFixedThreadPool(threadsNum);
    CompletionService<WordBag> completionService = new ExecutorCompletionService<WordBag>(
        executorService);
    int totalTaskCounter = 0;

    for (Entry<String, double[]> e : trainData.entrySet()) {
      // create and submit the job
      final DigitConversionJob job = new DigitConversionJob(e, params);
      completionService.submit(job);
      totalTaskCounter++;
    }

    // waiting for completion, shutdown pool disabling new tasks from being submitted
    executorService.shutdown();
    consoleLogger.info("Submitted " + totalTaskCounter + " jobs, shutting down the pool");

    try {

      while (totalTaskCounter > 0) {
        //
        // poll with a wait up to FOUR hours
        Future<WordBag> finished = completionService.poll(96, TimeUnit.HOURS);
        if (null == finished) {
          // something went wrong - break from here
          System.err.println("Breaking POLL loop after 48 HOURS of waiting...");
          break;
        }
        else {
          WordBag r = finished.get();
          String label = r.getLabel();
          r.setLabel(label.substring(0, label.indexOf("_")));
          res.put(label, r);
          totalTaskCounter--;
        }
        if (totalTaskCounter % 1000 == 0) {
          consoleLogger.info(totalTaskCounter + " jobs in the queue");
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

    return res;
  }

  private static Map<String, double[]> readTrainData(String fileName) throws NumberFormatException,
      IOException {

    Map<String, double[]> res = new HashMap<String, double[]>();

    BufferedReader br = new BufferedReader(new FileReader(new File(fileName)));

    String line = "";
    int counter = 0;
    while ((line = br.readLine()) != null) {

      if (line.trim().length() == 0) {
        continue;
      }

      String[] split = line.trim().split(",|\\s+");

      String label = split[0];

      double[] series = new double[split.length - 1];
      for (int i = 1; i < split.length; i++) {
        series[i - 1] = Double.valueOf(split[i].trim()).doubleValue();
      }

      res.put(label + "_" + String.valueOf(counter), series);

      counter++;
    }

    br.close();
    return res;
  }

  private static ArrayList<double[]> readTestData(String fileName) throws NumberFormatException,
      IOException {
    ArrayList<double[]> res = new ArrayList<double[]>();

    BufferedReader br = new BufferedReader(new FileReader(new File(fileName)));
    String line = "";
    while ((line = br.readLine()) != null) {

      if (line.trim().length() == 0) {
        continue;
      }

      String[] split = line.trim().split(",|\\s+");

      double[] series = new double[split.length];
      for (int i = 0; i < split.length; i++) {
        series[i] = Double.valueOf(split[i].trim()).doubleValue();
      }

      res.add(series);
    }

    br.close();
    return res;

  }

  private static Double parseValue(String string) {
    Double res = Double.NaN;
    try {
      Double r = Double.valueOf(string);
      res = r;
    }
    catch (NumberFormatException e) {
      assert true;
    }
    return res;
  }

}
