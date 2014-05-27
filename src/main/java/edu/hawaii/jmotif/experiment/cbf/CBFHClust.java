package edu.hawaii.jmotif.experiment.cbf;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import edu.hawaii.jmotif.sax.SAXFactory;
import edu.hawaii.jmotif.sax.alphabet.Alphabet;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.text.CosineDistanceMatrix;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.text.cluster.Cluster;
import edu.hawaii.jmotif.text.cluster.HC;
import edu.hawaii.jmotif.text.cluster.LinkageCriterion;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;

/**
 * Helper-runner for CBF Hierarchical web example test.
 * 
 * @author psenin
 * 
 */
public class CBFHClust {


  // prefix for all of the output
  private static final String PREFIX = "/home/psenin/dendroscope/";

  // we really need an alphabet for SAX
  private final static Alphabet a = new NormalAlphabet();

  // The timeseries length
  private static final int SERIES_LENGTH = 128;

  // Number of samples to generate from each subset
  private static final int SET_SAMPLES_NUM = 10;

  // Number of samples within the each bag of words
  private static final int TRAINING_SET_REPETITIONS = 1;

  // SAX parameters to use
  //
  private static final int PAA_SIZE = 6;
  private static final int ALPHABET_SIZE = 5;
  private static final int WINDOW_SIZE = 40;

  // processing strategy to utilize 
  //
  private static final SAXCollectionStrategy STRATEGY = SAXCollectionStrategy.NOREDUCTION;

  /**
   * @param args
   * @throws TSException
   * @throws IndexOutOfBoundsException
   * @throws IOException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, TSException, IOException {

    // time ticks
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
    Cluster clusters = HC.Hc(tfidf, LinkageCriterion.COMPLETE);

    System.out.println((new CosineDistanceMatrix(tfidf)).toString());

    BufferedWriter bw = new BufferedWriter(new FileWriter(PREFIX + "test.newick"));
    bw.write("(" + clusters.toNewick() + ")");
    bw.close();

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

}
