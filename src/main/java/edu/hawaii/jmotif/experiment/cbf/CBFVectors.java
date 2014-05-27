package edu.hawaii.jmotif.experiment.cbf;

import java.io.BufferedWriter;
import java.io.File;
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
import cc.mallet.util.Randoms;
import edu.hawaii.jmotif.sax.SAXFactory;
import edu.hawaii.jmotif.sax.alphabet.Alphabet;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;
import edu.hawaii.jmotif.util.BriefFormatter;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class CBFVectors {

  private static final int[] SAMPLING_POINTS = { 10, 50, 125, 250, 500, 750, 1000, 10000, 25000,
      50000, 75000, 100000, 150000, 200000, 500000, 1000000 };

  private static final int REPEATS = 2;

  private static int WINDOW_SIZE = 60;
  private static int PAA_SIZE = 7;
  private static int ALPHABET_SIZE = 7;
  private static SAXCollectionStrategy strategy = SAXCollectionStrategy.CLASSIC;

  private static Logger consoleLogger;

  private static String LOGGING_LEVEL = "FINE";

  private static Randoms randoms;

  private static final Alphabet a = new NormalAlphabet();

  private static final String COMMA = ",";

  private static final String CR = "\n";

  static {

    randoms = new Randoms();

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

    // WINDOW_SIZE = Integer.valueOf(args[0]);
    // PAA_SIZE = Integer.valueOf(args[1]);
    // ALPHABET_SIZE = Integer.valueOf(args[2]);
    //
    // if ("exact".equalsIgnoreCase(args[3])) {
    // strategy = SAXCollectionStrategy.EXACT;
    // }
    // else if ("classic".equalsIgnoreCase(args[3])) {
    // strategy = SAXCollectionStrategy.CLASSIC;
    // }

    String msg = "W: " + WINDOW_SIZE + ", PAA: " + PAA_SIZE + ", A: " + ALPHABET_SIZE + ", S: "
        + getStrategyPrefix(strategy);
    consoleLogger.info(msg);
    System.out.println("# " + msg);

    for (int rep = 0; rep < REPEATS; rep++) {

      for (int currentStep : SAMPLING_POINTS) {

        // making training and test collections
        Map<String, List<double[]>> trainData = getDataSet(currentStep);

        // building vectors
        //
        List<WordBag> bags = labeledSeries2WordBags(trainData, PAA_SIZE, ALPHABET_SIZE,
            WINDOW_SIZE, strategy);
        HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
        tfidf = TextUtils.normalizeToUnitVectors(tfidf);

        int totalWords = tfidf.get("0").size();
        int cylinderWords = countNonZero(tfidf.get("0"));
        int bellWords = countNonZero(tfidf.get("1"));
        int funnelWords = countNonZero(tfidf.get("2"));

        // the words nums
        System.out.print(currentStep + COMMA + totalWords + COMMA + cylinderWords + COMMA
            + bellWords + COMMA + funnelWords + CR);

        // if (currentStep == 1000) {

        // BufferedWriter bw = new BufferedWriter(new FileWriter("series.csv"));
        // for (Entry<String, List<double[]>> set : trainData.entrySet()) {
        // for (double[] series : set.getValue()) {
        // bw.write(set.getKey() + ",");
        // bw.write(Arrays.toString(series).toString().replace("[", "").replace("]", "") + CR);
        // }
        // }
        // bw.close();
        //
        // bw = new BufferedWriter(new FileWriter("table.csv"));
        // bw.write(TextUtils.tfidfToTable(tfidf));
        // bw.close();

        // pairwise words
        int areaBell = 0;
        int areaFunnel = 0;
        int areaCylinder = 0;
        int nCB = 0;
        int nCF = 0;
        int nBF = 0;
        int nCBF = 0;

        for (String w : tfidf.get("0").keySet()) {
          // cylinder
          if (tfidf.get("0").get(w) > 0) {
            areaCylinder++;
          }
          // bell
          if (tfidf.get("1").get(w) > 0) {
            areaBell++;
          }
          // funnel
          if (tfidf.get("2").get(w) > 0) {
            areaFunnel++;
          }
          // pairs
          if (tfidf.get("0").get(w) > 0 && tfidf.get("1").get(w) > 0) {
            nCB++;
          }
          if (tfidf.get("1").get(w) > 0 && tfidf.get("2").get(w) > 0) {
            nBF++;
          }
          if (tfidf.get("0").get(w) > 0 && tfidf.get("2").get(w) > 0) {
            nCF++;
          }
          // all together
          if (tfidf.get("0").get(w) > 0 && tfidf.get("1").get(w) > 0 && tfidf.get("2").get(w) > 0) {
            nCBF++;
          }
        }

        System.out.println("areaBell=" + Integer.valueOf(areaBell - nCB - nBF - nCBF));
        System.out.println("areaFunnel=" + Integer.valueOf(areaFunnel - nCF - nBF - nCBF));
        System.out.println("areaCylinder=" + Integer.valueOf(areaCylinder - nCF - nCB - nCBF));
        System.out.println("nCB=" + nCB);
        System.out.println("nCF=" + nCF);
        System.out.println("nBF=" + nBF);
        System.out.println("nCBF=" + nCBF);

        System.out.print(">" + currentStep + COMMA + totalWords + COMMA + cylinderWords + COMMA
            + bellWords + COMMA + funnelWords + COMMA 
            + String.valueOf(Integer.valueOf(areaBell - nCB - nBF - nCBF)) + COMMA
            + String.valueOf(Integer.valueOf(areaFunnel - nCF - nBF - nCBF)) + COMMA
            + String.valueOf(Integer.valueOf(areaCylinder - nCF - nCB - nCBF))
            + CR);
        
        // if (currentStep == 10) {
        // for (Entry<String, HashMap<String, Double>> e : tfidf.entrySet()) {
        // String className = e.getKey();
        // ArrayList<Entry<String, Double>> values = new ArrayList<Entry<String, Double>>();
        // values.addAll(e.getValue().entrySet());
        // Collections.sort(values, new TfIdfEntryComparator());
        // System.out.print("Class key: " + className + CR);
        // for (int i = 0; i < 10; i++) {
        // String pattern = values.get(i).getKey();
        // Double weight = values.get(i).getValue();
        // System.out.println("\"" + pattern + "\", " + weight);

      }
      // }

    }
  }

  private static int countNonZero(HashMap<String, Double> hashMap) {
    int res = 0;
    for (Entry<String, Double> e : hashMap.entrySet()) {
      if (e.getValue() > 0) {
        res++;
      }
    }
    return res;
  }

  private static List<WordBag> labeledSeries2WordBags(Map<String, List<double[]>> data,
      int paaSize, int alphabetSize, int windowSize, SAXCollectionStrategy strategy)
      throws IndexOutOfBoundsException, TSException {

    // make a map of resulting bags
    Map<String, WordBag> preRes = new HashMap<String, WordBag>();

    // process series one by one building word bags
    for (Entry<String, List<double[]>> e : data.entrySet()) {

      String classLabel = e.getKey();
      WordBag bag = new WordBag(classLabel);

      for (double[] series : e.getValue()) {
        //
        // series to words
        String oldStr = "";
        for (int i = 0; i <= series.length - windowSize; i++) {

          double[] paa = TSUtils.optimizedPaa(
              TSUtils.zNormalize(TSUtils.subseries(series, i, windowSize)), paaSize);

          char[] sax = TSUtils.ts2String(paa, a.getCuts(alphabetSize));

          if (SAXCollectionStrategy.CLASSIC.equals(strategy)) {
            if (oldStr.length() > 0 && SAXFactory.strDistance(sax, oldStr.toCharArray()) == 0) {
              continue;
            }
          }
          else if (SAXCollectionStrategy.EXACT.equals(strategy)) {
            if (oldStr.equalsIgnoreCase(String.valueOf(sax))) {
              continue;
            }
          }

          oldStr = String.valueOf(sax);

          bag.addWord(String.valueOf(sax));
        }
        //
        //
      }

      preRes.put(classLabel, bag);
      System.out.println(classLabel + ", " + bag.getWordSet().size());
    }

    List<WordBag> res = new ArrayList<WordBag>();
    res.addAll(preRes.values());
    return res;
  }

  private static Map<String, List<double[]>> damage(Map<String, List<double[]>> trainData,
      double d, double sd) {
    Map<String, List<double[]>> res = new HashMap<String, List<double[]>>();
    for (Entry<String, List<double[]>> referenceSet : trainData.entrySet()) {
      List<double[]> newData = new ArrayList<double[]>();
      int seriesCounter = 0;
      for (double[] referenceSeries : referenceSet.getValue()) {
        // if (seriesCounter > 3 && seriesCounter < 5) {
        // System.out.println(referenceSet.getKey() + " = " + Arrays.toString(referenceSeries));
        // }
        int noiseStart = Double.valueOf(Math.floor(randoms.nextUniform(0D, 128D * (1 - d))))
            .intValue();
        int noiseEnd = noiseStart + Double.valueOf(128D * d).intValue();
        for (int i = noiseStart; i < noiseEnd; i++) {
          referenceSeries[i] = randoms.nextGaussian(0, sd);
        }
        // if (seriesCounter > 3 && seriesCounter < 5) {
        // System.out.println(referenceSet.getKey() + "<-" + Arrays.toString(referenceSeries));
        // }
        newData.add(referenceSeries);
        seriesCounter++;
      }
      res.put(referenceSet.getKey(), newData);
    }
    return res;
  }

  private static void saveData(String fileName, Map<String, List<double[]>> data)
      throws IOException {
    BufferedWriter wr = new BufferedWriter(new FileWriter(new File(fileName)));
    for (Entry<String, List<double[]>> cClass : data.entrySet()) {
      for (double[] series : cClass.getValue()) {
        wr.write(String.valueOf(cClass.getKey()) + " "
            + Arrays.toString(series).replace("[", "").replace(", ", " ").replace("]", "\n"));
      }
    }
    wr.close();
  }

  private static Map<String, List<double[]>> getDataSet(int size) {

    Map<String, List<double[]>> res = new HashMap<String, List<double[]>>();

    // ticks - i.e. time
    int[] t = new int[128];
    for (int i = 0; i < 128; i++) {
      t[i] = i;
    }

    // cylinder sample
    List<double[]> cylinders = new ArrayList<double[]>();
    for (int i = 0; i < size; i++) {
      cylinders.add(CBFGenerator.cylinder(t));
    }
    res.put("0", cylinders);

    // bell sample
    List<double[]> bells = new ArrayList<double[]>();
    for (int i = 0; i < size; i++) {
      bells.add(CBFGenerator.bell(t));
    }
    res.put("1", bells);

    // funnel sample
    List<double[]> funnels = new ArrayList<double[]>();
    for (int i = 0; i < size; i++) {
      funnels.add(CBFGenerator.funnel(t));
    }
    res.put("2", funnels);

    return res;
  }

  protected static String getStrategyPrefix(SAXCollectionStrategy strategy) {
    String strategyP = "noreduction";
    if (SAXCollectionStrategy.EXACT.equals(strategy)) {
      strategyP = "exact";
    }
    if (SAXCollectionStrategy.CLASSIC.equals(strategy)) {
      strategy = SAXCollectionStrategy.CLASSIC;
      strategyP = "classic";
    }
    return strategyP;
  }
}
