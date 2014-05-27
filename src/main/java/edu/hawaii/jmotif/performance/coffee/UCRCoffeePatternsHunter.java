package edu.hawaii.jmotif.performance.coffee;

import java.io.IOException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.logging.ConsoleHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Logger;
import org.hackystat.utilities.logger.HackystatLogger;
import edu.hawaii.jmotif.performance.TfIdfEntryComparator;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.performance.UCRUtils;
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
public class UCRCoffeePatternsHunter extends UCRGenericClassifier {

  // prefix for all of the output
  private static final String TRAINING_DATA = "data/Coffee/Coffee_TRAIN";
  private static final String TEST_DATA = "data/Coffee/Coffee_TEST";

  // SAX parameters to try
  //
  private static final int[][] params = { { 90, 9, 9, CLASSIC } };

  private static final int MAX_PATTERNS_2PRINT = 3;
  private static final int MAX_SERIES_2PRINT = 5;
  private static final String CLASS_UNDER_INVESTIGATION = "1";

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

    // making training and test collections
    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(TRAINING_DATA);
    Map<String, List<double[]>> testData = UCRUtils.readUCRData(TEST_DATA);

    // loop over parameters
    for (int[] p : params) {

      // extract parameters
      int WINDOW_SIZE = p[0];
      int PAA_SIZE = p[1];
      int ALPHABET_SIZE = p[2];
      SAXCollectionStrategy strategy = SAXCollectionStrategy.CLASSIC;
      if (EXACT == p[3]) {
        strategy = SAXCollectionStrategy.EXACT;
      }
      else if (NOREDUCTION == p[3]) {
        strategy = SAXCollectionStrategy.NOREDUCTION;
      }

      // making training bags collection
      List<WordBag> bags = TextUtils.labeledSeries2WordBags(trainData, PAA_SIZE, ALPHABET_SIZE,
          WINDOW_SIZE, strategy);
      // get tfidf statistics
      HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
      // normalize all vectors
      tfidf = TextUtils.normalizeToUnitVectors(tfidf);

      // for (Entry<String, HashMap<String, Double>> entry : tfidf.entrySet()) {
      // ArrayList<Entry<String, Double>> values = new ArrayList<Entry<String, Double>>();
      // values.addAll(entry.getValue().entrySet());
      // Collections.sort(values, new TfIdfEntryComparator());
      // HashMap<String, Double> newVector = new HashMap<String, Double>();
      // for (int i = 0; i < 30; i++) {
      // newVector.put(values.get(i).getKey(), values.get(i).getValue());
      // }
      // tfidf.put(entry.getKey(), newVector);
      // }

      // get best patterns for each class
      DecimalFormat df = new DecimalFormat("0.00##");
      for (Entry<String, HashMap<String, Double>> e : tfidf.entrySet()) {
        String className = e.getKey();
        if (!(className.equalsIgnoreCase(CLASS_UNDER_INVESTIGATION))) {
          continue;
        }
        ArrayList<Entry<String, Double>> values = new ArrayList<Entry<String, Double>>();
        values.addAll(e.getValue().entrySet());
        Collections.sort(values, new TfIdfEntryComparator());
        System.out.print("Class key: " + className + CR);
        for (int i = 0; i < MAX_PATTERNS_2PRINT; i++) {
          String pattern = values.get(i).getKey();
          Double weight = values.get(i).getValue();
          System.out.println("pattern=\"" + pattern + "\"; weight=" + df.format(weight));

          StringBuffer seriesBuff = new StringBuffer("series = c(");
          StringBuffer offsetBuff = new StringBuffer("offsets = c(");
          Map<Integer, Integer[]> hits = getPatternLocationsForTheClass(className, trainData,
              pattern, WINDOW_SIZE, PAA_SIZE, ALPHABET_SIZE);
          int k = 0;
          int printedK = 0;
          do {
            if (hits.get(k).length > 0) {
              System.out.println(k + ": " + Arrays.toString(hits.get(k)));
              for (int offset : hits.get(k)) {
                seriesBuff.append(String.valueOf(k + 1) + ",");
                offsetBuff.append(String.valueOf(offset + 1) + ",");
              }
              printedK++;
            }
            k++;
          }
          while (k < hits.size() && printedK < MAX_SERIES_2PRINT);

          System.out.print(seriesBuff.delete(seriesBuff.length() - 1, seriesBuff.length())
              .toString() + ")" + CR);
          System.out.print(offsetBuff.delete(offsetBuff.length() - 1, offsetBuff.length())
              .toString() + ")" + CR + "#" + CR);

        }
        List<double[]> testD = testData.get(CLASS_UNDER_INVESTIGATION);
        int seriesIdx = 0;
        for (double[] series : testD) {
          int classificationResult = TextUtils.classify(className, series, tfidf, PAA_SIZE,
              ALPHABET_SIZE, WINDOW_SIZE, strategy);
          if (0 == classificationResult) {
            System.out.println(seriesIdx + 1);
          }
          seriesIdx++;
        }
      }

    }
  }

  private static Map<Integer, Integer[]> getPatternLocationsForTheClass(String className,
      Map<String, List<double[]>> trainData, String pattern, int windowSize, int paaSize,
      int alphabetSize) throws IndexOutOfBoundsException, TSException {

    Alphabet a = new NormalAlphabet();

    Map<Integer, Integer[]> res = new HashMap<Integer, Integer[]>();

    int seriesCounter = 0;
    for (double[] series : trainData.get(className)) {

      List<Integer> arr = new ArrayList<Integer>();

      for (int i = 0; i <= series.length - windowSize; i++) {
        double[] paa = TSUtils.paa(TSUtils.zNormalize(TSUtils.subseries(series, i, windowSize)),
            paaSize);
        char[] sax = TSUtils.ts2String(paa, a.getCuts(alphabetSize));
        if (pattern.equalsIgnoreCase(String.valueOf(sax))) {
          arr.add(i);
        }
      }

      res.put(seriesCounter, arr.toArray(new Integer[0]));
      seriesCounter++;
    }

    return res;
  }
}
