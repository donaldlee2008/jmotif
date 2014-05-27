package edu.hawaii.jmotif.experiment.cbf;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.TreeSet;
import edu.hawaii.jmotif.sax.SAXFactory;
import edu.hawaii.jmotif.sax.alphabet.Alphabet;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.text.cluster.FurthestFirstStrategy;
import edu.hawaii.jmotif.text.cluster.TextKMeans;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class CBFKMeans {

  // string constants
  private static final String COMMA = ",";

  // prefix for all of the output
  private static final String PREFIX = "RCode/clustering/";

  // various variables
  private final static Alphabet a = new NormalAlphabet();
  private static final DecimalFormat df = new DecimalFormat("#0.0000000000");

  // classifier test parameters
  //
  /** The timeseries length. */
  private static final int SERIES_LENGTH = 128;

  /** Number of samples to generate from each subset. */
  private static final int SET_SAMPLES_NUM = 4;

  /** Number of samples within the each bag of words. */
  private static final int TRAINING_SET_REPETITIONS = 2;

  // SAX parameters to use
  //
  private static final int PAA_SIZE = 4;
  private static final int ALPHABET_SIZE = 3;
  private static final int WINDOW_SIZE = 60;

  private static final SAXCollectionStrategy STRATEGY = SAXCollectionStrategy.EXACT;

  /**
   * @param args
   * @throws TSException
   * @throws IndexOutOfBoundsException
   * @throws IOException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, TSException, IOException {

    // ticks
    int[] t = new int[SERIES_LENGTH];
    for (int i = 0; i < SERIES_LENGTH; i++) {
      t[i] = i;
    }

    // cylinder sample
    double[][] cylinder = new double[SET_SAMPLES_NUM * TRAINING_SET_REPETITIONS][SERIES_LENGTH];
    for (int i = 0; i < cylinder.length; i++) {
      cylinder[i] = CBFGenerator.cylinder(t);
    }

    // bell sample
    double[][] bell = new double[SET_SAMPLES_NUM * TRAINING_SET_REPETITIONS][SERIES_LENGTH];
    for (int i = 0; i < bell.length; i++) {
      bell[i] = CBFGenerator.bell(t);
    }

    // funnel sample
    double[][] funnel = new double[SET_SAMPLES_NUM * TRAINING_SET_REPETITIONS][SERIES_LENGTH];
    for (int i = 0; i < funnel.length; i++) {
      funnel[i] = CBFGenerator.funnel(t);
    }

    // making bags collection
    List<WordBag> bags = new ArrayList<WordBag>();
    bags.addAll(getWordBags("cylinder", cylinder, TRAINING_SET_REPETITIONS, WINDOW_SIZE, PAA_SIZE,
        ALPHABET_SIZE));
    bags.addAll(getWordBags("bell", bell, TRAINING_SET_REPETITIONS, WINDOW_SIZE, PAA_SIZE,
        ALPHABET_SIZE));
    bags.addAll(getWordBags("funnel", funnel, TRAINING_SET_REPETITIONS, WINDOW_SIZE, PAA_SIZE,
        ALPHABET_SIZE));

    // for (WordBag b : bags) {
    // System.out.println(b.getName());
    // }

    // create the TFIDF data structure
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
    tfidf = TextUtils.normalizeToUnitVectors(tfidf);

    // launch KMeans with random centers
    @SuppressWarnings("unused")
    HashMap<String, List<String>> clusters = TextKMeans.cluster(tfidf, 3,
        new FurthestFirstStrategy());

    // write down tf*idf vectors for each class
    writePreClusterTable(tfidf, PREFIX + "cylinder-bell-funnel.csv");

  }

  private static List<WordBag> getWordBags(String bagPrefix, double[][] series, int repeats,
      int windowSize, int paaSize, int alphabetSize) throws IndexOutOfBoundsException, TSException,
      IOException {
    List<WordBag> res = new ArrayList<WordBag>();
    for (int i = 0; i < series.length / repeats; i++) {
      WordBag bag = new WordBag(bagPrefix + String.valueOf(i));
      for (int r = 0; r < repeats; r++) {
        int seriesIdx = i + r;
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
