package edu.hawaii.jmotif.performance.hilbert;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
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
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.sax.alphabet.Alphabet;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;
import edu.hawaii.jmotif.util.BriefFormatter;

/**
 * Hunts for best scoring patterns for the class and prints them out.
 * 
 * @author psenin
 * 
 */
public class HilbertPatternsHunter extends UCRGenericClassifier {

  // prefix for all of the output
  private static final String CLASS_A = "data/hilbert/normal_hilbert_curve.csv";
  private static final String CLASS_B = "data/hilbert/anomaly_hilbert_curve.csv";

  // SAX parameters to try
  //
  private static final int[] params = { 100, 10, 5, NOREDUCTION };

  private static Logger consoleLogger;

  private static String LOGGING_LEVEL = "FINE";

  // static logger init block
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

    int WINDOW_SIZE = params[0];
    int PAA_SIZE = params[1];
    int ALPHABET_SIZE = params[2];

    // making training and test collections
    double[] normal = readData("1", CLASS_A);
    double[] anomaly = readData("2", CLASS_B);

    // making training bags collection
    List<WordBag> bags = new ArrayList<WordBag>();

    bags.add(TextUtils.seriesToWordBag("Normal", normal, params));

    bags.add(TextUtils.seriesToWordBag("Anomaly", anomaly, params));

    // get tfidf statistics
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);

    // normalize all vectors
    tfidf = TextUtils.normalizeToUnitVectors(tfidf);

    System.out.println(TextUtils.tfidfToTable(tfidf));

    // series A as heat
    System.out.println(Arrays.toString(TSUtils.zNormalize(normal)).replace("[", "")
        .replace("]", ""));
    System.out
        .println(Arrays
            .toString(
                seriesValuesAsHeat(normal, "Normal", tfidf, WINDOW_SIZE, PAA_SIZE, ALPHABET_SIZE))
            .replace("[", "").replace("]", ""));

    // series A as heat
    System.out.println(Arrays.toString(TSUtils.zNormalize(anomaly)).replace("[", "")
        .replace("]", ""));
    System.out.println(Arrays
        .toString(
            seriesValuesAsHeat(anomaly, "Anomaly", tfidf, WINDOW_SIZE, PAA_SIZE, ALPHABET_SIZE))
        .replace("[", "").replace("]", ""));

  }

  private static double[] readData(String string, String fname) throws IOException {
    BufferedReader br = new BufferedReader(new FileReader(new File(fname)));
    String str = null;
    ArrayList<Double> series = new ArrayList<Double>();
    while ((str = br.readLine()) != null) {
      if (str.trim().length() > 0) {
        series.add(Double.valueOf(str.split(",")[1]));
      }
    }
    br.close();
    double[] res = new double[series.size()];
    for (int i = 0; i < series.size(); i++) {
      res[i] = series.get(i);
    }
    return res;
  }

  private static double[] seriesValuesAsHeat(double[] series, String className,
      HashMap<String, HashMap<String, Double>> tfidf, int window_size, int paa_size,
      int alphabet_size) throws TSException {

    Alphabet a = new NormalAlphabet();

    double[] weights = new double[series.length];

    HashMap<String, Integer> words = new HashMap<String, Integer>();

    for (int i = 0; i <= series.length - window_size; i++) {
      double[] subseries = TSUtils.subseries(series, i, window_size);
      double[] paa = TSUtils.paa(TSUtils.zNormalize(subseries), paa_size);
      char[] sax = TSUtils.ts2String(paa, a.getCuts(alphabet_size));
      words.put(String.valueOf(sax), i);
    }

    for (Entry<String, HashMap<String, Double>> e : tfidf.entrySet()) {
      for (Entry<String, Double> e1 : e.getValue().entrySet()) {
        if (words.containsKey(e1.getKey())) {
          double increment = 0.0;
          int index = words.get(e1.getKey());
          if (className.equalsIgnoreCase(e.getKey())) {
            increment = e1.getValue();
          }
          else {
            increment = -e1.getValue();
          }
          for (int i = 0; i < window_size; i++) {
            weights[index + i] = weights[index + i] + increment;
          }
        }
      }
    }

    return weights;

  }

}
