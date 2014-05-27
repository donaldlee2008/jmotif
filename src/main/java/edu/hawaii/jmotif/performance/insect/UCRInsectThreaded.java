package edu.hawaii.jmotif.performance.insect;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class UCRInsectThreaded extends UCRGenericClassifier {

  // data
  //
  // private static final String TRAINING_DATA = "/media/Stock/sounds/try50.txt";

  // output prefix
  //
  private static final String outputPrefix = "insect_threaded_";

  // SAX parameters to use
  //
  // private static final int WINDOW_MIN = 15;
  // private static final int WINDOW_MAX = 300;
  // private static final int WINDOW_INCREMENT = 3;
  //
  // private static final int PAA_MIN = 5;
  // private static final int PAA_MAX = 50;
  // private static final int PAA_INCREMENT = 3;
  //
  // private static final int ALPHABET_MIN = 3;
  // private static final int ALPHABET_MAX = 15;
  // private static final int ALPHABET_INCREMENT = 2;

  // leave out parameters
  //
  // private static final int LEAVE_OUT_NUM = 10;
  // private static final int THREADS_NUM = 8;

  private UCRInsectThreaded() {
    super();
  }

  /**
   * @param args
   * @throws Exception
   */
  public static void main(String[] args) throws Exception {

    System.out.println("= Configuration ==============================");
    String datFileName = args[0];
    String holdoutNum = args[1];
    String threadsNum = args[2];
    System.out.println("Data: " + datFileName + ", holdout: " + holdoutNum + ", threads: "
        + threadsNum);

    String wStart = args[3];
    String wEnd = args[4];
    String wIncrement = args[5];
    System.out.println("Window: start " + wStart + ", end " + wEnd + ", increment " + wIncrement);

    String pStart = args[6];
    String pEnd = args[7];
    String pIncrement = args[8];
    System.out.println("PAA: start " + pStart + ", end " + pEnd + ", increment " + pIncrement);

    String aStart = args[9];
    String aEnd = args[10];
    String aIncrement = args[11];
    System.out.println("Alphabet: start " + aStart + ", end " + aEnd + ", increment " + aIncrement);

    String strategyP = args[12];
    System.out.println("Strategy: " + strategyP);
    System.out.println("= End configuration ==============================");

    // configuring strategy
    //
    SAXCollectionStrategy strategy = SAXCollectionStrategy.NOREDUCTION;
    String strategyPrefix = "noreduction";
    if (args.length > 0) {
      if ("EXACT".equalsIgnoreCase(strategyP)) {
        strategy = SAXCollectionStrategy.EXACT;
        strategyPrefix = "exact";
      }
      if ("CLASSIC".equalsIgnoreCase(strategyP)) {
        strategy = SAXCollectionStrategy.CLASSIC;
        strategyPrefix = "classic";
      }
    }
    consoleLogger.fine("strategy: " + strategyPrefix + ", leaving out: "
        + Integer.valueOf(holdoutNum));

    // make up window sizes
    int[] window_sizes = makeArray(Integer.valueOf(wStart), Integer.valueOf(wEnd),
        Integer.valueOf(wIncrement));

    // make up paa sizes
    int[] paa_sizes = makeArray(Integer.valueOf(pStart), Integer.valueOf(pEnd),
        Integer.valueOf(pIncrement));

    // make up alphabet sizes
    int[] alphabet_sizes = makeArray(Integer.valueOf(aStart), Integer.valueOf(aEnd),
        Integer.valueOf(aIncrement));

    // reading training and test collections
    //
    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(datFileName);
    consoleLogger.fine("trainData classes: " + trainData.size() + ", series length: "
        + trainData.entrySet().iterator().next().getValue().get(0).length);
    for (Entry<String, List<double[]>> e : trainData.entrySet()) {
      consoleLogger.fine(" training class: " + e.getKey() + " series: " + e.getValue().size());
    }

    List<String> result = trainKNNFoldJMotifThreaded(Integer.valueOf(threadsNum), window_sizes,
        paa_sizes, alphabet_sizes, strategy, trainData, Integer.valueOf(holdoutNum));

    BufferedWriter bw = new BufferedWriter(new FileWriter(outputPrefix + "_" + strategyPrefix + "_"
        + Integer.valueOf(holdoutNum) + ".csv"));

    for (String line : result) {
      bw.write(line + CR);
    }
    bw.close();

  }

}
