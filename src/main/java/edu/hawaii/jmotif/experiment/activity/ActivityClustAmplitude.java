package edu.hawaii.jmotif.experiment.activity;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.TreeSet;
import edu.hawaii.jmotif.sax.SAXFactory;
import edu.hawaii.jmotif.sax.alphabet.Alphabet;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.text.CosineDistanceMatrix;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.text.cluster.Cluster;
import edu.hawaii.jmotif.text.cluster.FurthestFirstStrategy;
import edu.hawaii.jmotif.text.cluster.HC;
import edu.hawaii.jmotif.text.cluster.LinkageCriterion;
import edu.hawaii.jmotif.text.cluster.TextKMeans;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;

/**
 * Helper-runner for White Paper span example.
 * 
 * @author psenin
 * 
 */
public class ActivityClustAmplitude {

  // string constants
  private static final String COMMA = ",";

  private static final DecimalFormat df = new DecimalFormat("#0.0000000000");

  // prefix for all of the output
  private static final String PREFIX = "RCode/activity/";

  // we really need an alphabet for SAX
  private final static Alphabet a = new NormalAlphabet();

  // The timeseries length
  private static final int SERIES_LENGTH = 60;

  // Number of samples to generate from each subset
  private static final int SET_SAMPLES_NUM = 5;

  // SAX parameters to use
  //
  private static final int PAA_SIZE = 4;
  private static final int ALPHABET_SIZE = 8;
  private static final int WINDOW_SIZE = 8;

  // processing strategy to utilize
  //
  private static final SAXCollectionStrategy STRATEGY = SAXCollectionStrategy.CLASSIC;

  /**
   * Main runnable.
   * 
   * @param args None used.
   * @throws TSException
   * @throws IndexOutOfBoundsException
   * @throws IOException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, TSException, IOException {

    // one hour runs
    double[][] one = new double[SET_SAMPLES_NUM][SERIES_LENGTH];
    for (int i = 0; i < one.length; i++) {
      one[i] = ActivityGenerator.threePeriodsOfAmplitude(SERIES_LENGTH, new int[] { 2, 2, 2 },
          new int[] { 2, 2, 2 });
    }

    // two hours runs
    double[][] two = new double[SET_SAMPLES_NUM][SERIES_LENGTH];
    for (int i = 0; i < two.length; i++) {
      two[i] = ActivityGenerator.threePeriodsOfAmplitude(SERIES_LENGTH, new int[] { 2, 2, 2 },
          new int[] { 3, 3, 3 });
    }

    // three hours runs
    double[][] three = new double[SET_SAMPLES_NUM][SERIES_LENGTH];
    for (int i = 0; i < three.length; i++) {
      three[i] = ActivityGenerator.threePeriodsOfAmplitude(SERIES_LENGTH, new int[] { 2, 2, 2 },
          new int[] { 4, 4, 4 });
    }

    // write down the series
    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(PREFIX
        + "test-amplitude-series.csv")));
    for (int i = 0; i < one.length; i++) {
      String str = "one".concat(String.valueOf(i))
          + Arrays.toString(one[i]).replace("[", " ").replace("]", "").replace(", ", " ") + "\n";
      bw.write(str);
    }
    for (int i = 0; i < two.length; i++) {
      String str = "two".concat(String.valueOf(i))
          + Arrays.toString(two[i]).replace("[", " ").replace("]", "").replace(", ", " ") + "\n";
      bw.write(str);
    }
    for (int i = 0; i < two.length; i++) {
      String str = "three".concat(String.valueOf(i))
          + Arrays.toString(three[i]).replace("[", " ").replace("]", "").replace(", ", " ") + "\n";
      bw.write(str);
    }
    bw.close();

    // making bags collection
    //
    List<WordBag> bags = new ArrayList<WordBag>();
    bags.addAll(getWordBagsNoNormalization("one", one, WINDOW_SIZE, PAA_SIZE, ALPHABET_SIZE));
    bags.addAll(getWordBagsNoNormalization("two", two, WINDOW_SIZE, PAA_SIZE, ALPHABET_SIZE));
    bags.addAll(getWordBagsNoNormalization("three", three, WINDOW_SIZE, PAA_SIZE, ALPHABET_SIZE));

    // build the TFIDF data structure
    //
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
    tfidf = TextUtils.normalizeToUnitVectors(tfidf);
    bw = new BufferedWriter(new FileWriter(new File(PREFIX + "test-amplitude-cosineDM.csv")));
    bw.write(new CosineDistanceMatrix(tfidf).toString() + "\n");
    bw.close();

    // launch HC algorithm
    //
    Cluster clusters = HC.Hc(tfidf, LinkageCriterion.COMPLETE);
    bw = new BufferedWriter(new FileWriter(PREFIX + "test-amplitude-HC-SAX-VSM.newick"));
    bw.write("(" + clusters.toNewick() + ")");
    bw.close();

    // launch KMeans with random centers
    HashMap<String, List<String>> kClusters = TextKMeans.cluster(tfidf, 3,
        new FurthestFirstStrategy());

    // write down tf*idf vectors for each class
    writePreClusterTable(tfidf, PREFIX + "test-amplitude-terms.csv");

  }

  private static List<WordBag> getWordBags(String bagPrefix, double[][] series, int windowSize,
      int paaSize, int alphabetSize) throws IndexOutOfBoundsException, TSException, IOException {
    List<WordBag> res = new ArrayList<WordBag>();
    for (int i = 0; i < series.length; i++) {
      WordBag bag = new WordBag(bagPrefix + String.valueOf(i));
      int seriesIdx = i;
      String oldStr = "";
      for (int j = 0; j < series[seriesIdx].length - windowSize; j++) {
        double[] paa = TSUtils.paa(
            TSUtils.zNormalize(TSUtils.subseries(series[seriesIdx], j, windowSize)), PAA_SIZE);
        char[] sax = TSUtils.ts2String(paa, a.getCuts(ALPHABET_SIZE));
        if (SAXCollectionStrategy.CLASSIC.equals(STRATEGY)) {
          if (oldStr.length() > 0 && SAXFactory.strDistance(sax, oldStr.toCharArray()) == 0) {
            continue;
          }
        }
        else if (SAXCollectionStrategy.EXACT.equals(STRATEGY)) {
          if (oldStr.equalsIgnoreCase(String.valueOf(sax))) {
            continue;
          }
        }
        oldStr = String.valueOf(sax);
        bag.addWord(String.valueOf(sax));
      }
      res.add(bag);
    }
    return res;
  }

  private static List<WordBag> getWordBagsNoNormalization(String bagPrefix, double[][] series,
      int windowSize, int paaSize, int alphabetSize) throws IndexOutOfBoundsException, TSException,
      IOException {
    List<WordBag> res = new ArrayList<WordBag>();
    for (int i = 0; i < series.length; i++) {
      WordBag bag = new WordBag(bagPrefix + String.valueOf(i));
      int seriesIdx = i;

      double[] ser = TSUtils.zNormalize(Arrays.copyOf(series[seriesIdx], series[seriesIdx].length));
      

      String oldStr = "";
      for (int j = 0; j < ser.length - windowSize; j++) {
        double[] paa = TSUtils.paa(TSUtils.subseries(ser, j, windowSize), PAA_SIZE);
        char[] sax = TSUtils.ts2String(paa, a.getCuts(ALPHABET_SIZE));
        if (SAXCollectionStrategy.CLASSIC.equals(STRATEGY)) {
          if (oldStr.length() > 0 && SAXFactory.strDistance(sax, oldStr.toCharArray()) == 0) {
            continue;
          }
        }
        else if (SAXCollectionStrategy.EXACT.equals(STRATEGY)) {
          if (oldStr.equalsIgnoreCase(String.valueOf(sax))) {
            continue;
          }
        }
        oldStr = String.valueOf(sax);
        bag.addWord(String.valueOf(sax));
      }
      res.add(bag);
    }
    return res;
  }

  private static void writePreClusterTable(HashMap<String, HashMap<String, Double>> tfidf,
      String fname) throws IOException {

    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(fname)));
    // melt together sets of keys
    //
    TreeSet<String> words = new TreeSet<String>();
    for (HashMap<String, Double> t : tfidf.values()) {
      words.addAll(t.keySet());
    }

    // print keys - the dictionaries names
    //
    StringBuilder sb = new StringBuilder("\"\",");
    for (String key : tfidf.keySet()) {
      sb.append("\"").append(key).append("\",");
    }
    bw.write(sb.delete(sb.length() - 1, sb.length()).append("\n").toString());

    // print rows, one by one
    //
    for (String w : words) {
      sb = new StringBuilder();
      sb.append("\"").append(w).append("\",");
      for (String key : tfidf.keySet()) {
        HashMap<String, Double> data = tfidf.get(key);
        if (data.keySet().contains(w)) {
          sb.append(df.format(data.get(w))).append(COMMA);
        }
        else {
          sb.append(df.format(0.0d)).append(COMMA);
        }
      }
      bw.write(sb.delete(sb.length() - 1, sb.length()).append("\n").toString());
    }
    bw.close();
  }

}
