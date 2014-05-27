package edu.hawaii.jmotif.experiment.synthetic;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.logging.ConsoleHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Logger;
import org.hackystat.utilities.logger.HackystatLogger;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.CosineDistanceMatrix;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.text.cluster.Cluster;
import edu.hawaii.jmotif.text.cluster.HC;
import edu.hawaii.jmotif.text.cluster.LinkageCriterion;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.util.BriefFormatter;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class SyntheticControlHClust {

  // series to take
  private static final int SERIES_NUM = 2;

  // prefix for all of the output
  private static final String PREFIX = "/home/psenin/dendroscope/";

  // data locations
  private static final String TRAINING_DATA = "data/synthetic_control/synthetic_control_TRAIN";
  private static final String TEST_DATA = "data/synthetic_control/synthetic_control_TEST";

  // SAX parameters to use
  //
  private static final int WINDOW_SIZE = 45;
  private static final int PAA_SIZE = 5;
  private static final int ALPHABET_SIZE = 5;

  private static final SAXCollectionStrategy STRATEGY = SAXCollectionStrategy.EXACT;

  protected static Logger consoleLogger;
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

    int[][] params = new int[1][4];
    params[0][0] = WINDOW_SIZE;
    params[0][1] = PAA_SIZE;
    params[0][2] = ALPHABET_SIZE;
    params[0][3] = STRATEGY.index();

    // reading training and test collections
    //
    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(TRAINING_DATA);
    consoleLogger.fine("trainData classes: " + trainData.size() + ", series length: "
        + trainData.entrySet().iterator().next().getValue().get(0).length);
    for (Entry<String, List<double[]>> e : trainData.entrySet()) {
      consoleLogger.fine(" training class: " + e.getKey() + " series: " + e.getValue().size());
    }

    // make a map of resulting bags
    List<WordBag> preRes = new ArrayList<WordBag>();

    // process series one by one building word bags
    for (Entry<String, List<double[]>> e : trainData.entrySet()) {

      String classLabel = e.getKey();
      if (classLabel.equalsIgnoreCase("2") || classLabel.equalsIgnoreCase("3")
          || classLabel.equalsIgnoreCase("6")) {
        continue;
      }

      int i = 0;
      int skip = 0;
      for (double[] series : e.getValue()) {
        skip++;
//        if (skip < 0) {
        if (skip < 15) {
          continue;
        }
        WordBag cb = TextUtils.seriesToWordBag(classLabel + String.valueOf(i), series, params[0]);
        System.out.println("series" + classLabel + String.valueOf(i) + " = c"
            + Arrays.toString(series).replace("[", "(").replace("]", ")"));
        preRes.add(cb);
        i++;
        if (i > SERIES_NUM) {
          break;
        }
      }

    }

    // compute TFIDF statistics for training set
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(preRes);

    // normalize to unit vectors to avoid false discrimination by vector magnitude
    tfidf = TextUtils.normalizeToUnitVectors(tfidf);

    // launch KMeans with random centers
    Cluster clusters = HC.Hc(tfidf, LinkageCriterion.SINGLE);

    System.out.println((new CosineDistanceMatrix(tfidf)).toString());

    BufferedWriter bw = new BufferedWriter(new FileWriter(PREFIX + "test.newick"));
    bw.write("(" + clusters.toNewick() + ")");
    bw.close();

  }

}
