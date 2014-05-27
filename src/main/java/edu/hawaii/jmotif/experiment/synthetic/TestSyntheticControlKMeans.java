package edu.hawaii.jmotif.experiment.synthetic;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
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
public class TestSyntheticControlKMeans {

  // string constants
  private static final String COMMA = ",";

  // prefix for all of the output
  private static final String PREFIX = "RCode/synthetic.control/";

  // various variables
  private final static Alphabet a = new NormalAlphabet();
  private static final DecimalFormat df = new DecimalFormat("#0.0000000000");

  // SAX parameters to use
  //
  // private static final int WINDOW_SIZE1 = 12;
  // private static final int PAA_SIZE1 = 4;
  // private static final int ALPHABET_SIZE1 = 3;
  // private static final int[][] params = { { 9, 3, 3 }, { 15, 3, 3 }, { 12, 3, 5 }, { 45, 3, 3 }
  // };

  // private static final int[][] params = { { 12, 3, 5 }, { 44, 4, 5 } };
  private static final int[][] params = { { 15, 5, 5 }, { 44, 4, 6 } };

  private static final SAXCollectionStrategy STRATEGY = SAXCollectionStrategy.EXACT;

  private static final Integer NUM_CLUSTERS = 2;

  /**
   * @param args
   * @throws TSException
   * @throws IndexOutOfBoundsException
   * @throws IOException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, TSException, IOException {

    // get the data loaded into memory
    //
    double[][] data = new double[600][60];
    BufferedReader br = new BufferedReader(new FileReader(PREFIX + "synthetic_control.data"));
    String line = null;
    int i = 0;
    while ((line = br.readLine()) != null) {
      String[] dat = line.split("\\s+");
      for (int j = 0; j < 60; j++) {
        data[i][j] = Double.valueOf(dat[j]).doubleValue();
      }
      i++;
    }

    List<WordBag> bags = new ArrayList<WordBag>();
    String tag = "A";
    for (int k = 0; k < 600; k++) {
      if (k > 99) {
        tag = "B";
      }
      if (k > 199) {
        tag = "C";
      }
      if (k > 299) {
        tag = "D";
      }
      if (k > 399) {
        tag = "E";
      }
      if (k > 499) {
        tag = "F";
      }

      if ("E".equalsIgnoreCase(tag) || "C".equalsIgnoreCase(tag))
        bags.add(makeAbag(tag, k, data[k], params));

      if (k == 9) {
        k = 99;
      }
      if (k == 109) {
        k = 199;
      }
      if (k == 209) {
        k = 299;
      }
      if (k == 309) {
        k = 399;
      }
      if (k == 409) {
        k = 499;
      }
      if (k == 509) {
        break;
      }

    }

    // create the TFIDF data structure
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
    tfidf = TextUtils.normalizeToUnitVectors(tfidf);

    // launch KMeans with random centers
    // Cluster clusters = HC.Hc(tfidf, LinkageCriterion.SINGLE);
    //
    // BufferedWriter bw = new BufferedWriter(new FileWriter(PREFIX + "test.newick"));
    // bw.write("(" + clusters.toNewick() + ")");
    // bw.close();

    // launch KMeans with random centers
    HashMap<String, List<String>> clusters = TextKMeans.cluster(tfidf, NUM_CLUSTERS,
        new FurthestFirstStrategy());

  }

  private static WordBag makeAbag(String tag, int k, double[] ds, int[][] params)
      throws IndexOutOfBoundsException, TSException {

    WordBag bag = new WordBag(tag + String.valueOf(k));

    for (int[] p : params) {

      String oldStr = "";
      int ws = p[0];
      int paaNum = p[1];
      int aSize = p[2];

      for (int j = 0; j < ds.length - ws; j++) {
        double[] paa = TSUtils.paa(TSUtils.zNormalize(TSUtils.subseries(ds, j, ws)), paaNum);
        char[] sax = TSUtils.ts2String(paa, a.getCuts(aSize));
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

    return bag;
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
