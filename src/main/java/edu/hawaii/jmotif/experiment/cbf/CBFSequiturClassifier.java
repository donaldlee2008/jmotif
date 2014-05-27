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
import edu.hawaii.jmotif.sequitur.SequiturFactory;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.timeseries.TSException;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class CBFSequiturClassifier {

  // various variables

  // classifier test parameters
  //
  /** The timeseries length. */
  private static final int SERIES_LENGTH = 128;

  /**
   * @param args
   * @throws TSException
   * @throws IndexOutOfBoundsException
   * @throws IOException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, TSException, IOException {

    if (6 != args.length) {
      System.out.println("Expecting parameters W P A Strategy trainSize testSize");
    }

    Integer windowSize = Integer.valueOf(args[0]);
    Integer paaSize = Integer.valueOf(args[1]);
    Integer alphabetSize = Integer.valueOf(args[2]);

    SAXCollectionStrategy strategy = SAXCollectionStrategy.NOREDUCTION;

    if ("exact".equalsIgnoreCase(args[3])) {
      strategy = SAXCollectionStrategy.EXACT;
    }
    else if ("classic".equalsIgnoreCase(args[3])) {
      strategy = SAXCollectionStrategy.CLASSIC;
    }

    Integer trainSize = Integer.valueOf(args[4]);
    Integer testSize = Integer.valueOf(args[5]);

    // making training and test collections
    Map<String, List<double[]>> trainSet = makeSet(trainSize);
    Map<String, List<double[]>> testSet = makeSet(testSize);

    if (windowSize < paaSize + 1) {
      System.exit(0);
    }

    long tfidfStart = System.currentTimeMillis();
    // making training bags collection
    List<WordBag> bags = TextUtils.labeledSeries2WordBags(trainSet, paaSize, alphabetSize,
        windowSize, strategy);
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
    tfidf = TextUtils.normalizeToUnitVectors(tfidf);
    long tfidfEnd = System.currentTimeMillis();

    List<WordBag> bagsS = SequiturFactory.labeledSeries2WordBags(trainSet, paaSize, alphabetSize,
        windowSize, strategy);
    HashMap<String, HashMap<String, Double>> tfidfS = TextUtils.computeTFIDF(bagsS);
    tfidfS = TextUtils.normalizeToUnitVectors(tfidfS);
    long tfidfEndS = System.currentTimeMillis();

    // System.out.println(TextUtils.bagsToTable(bags));

    int totalTestSample = 0;
    int totalPositiveTests = 0;

    for (String label : tfidf.keySet()) {
      List<double[]> testD = testSet.get(label);
      int positives = 0;
      for (double[] series : testD) {
        positives = positives
            + TextUtils.classify(label, series, tfidf, paaSize, alphabetSize, windowSize, strategy);
        totalTestSample++;
      }
      totalPositiveTests = totalPositiveTests + positives;
    }
    double accuracy = (double) totalPositiveTests / (double) totalTestSample;
    double error = 1.0d - accuracy;
    long tfidfClassEnd = System.currentTimeMillis();

    totalTestSample = 0;
    int totalPositiveTestsS = 0;

    for (String label : tfidf.keySet()) {
      List<double[]> testD = testSet.get(label);
      int positivesS = 0;
      for (double[] series : testD) {
        positivesS = positivesS
            + SequiturFactory.classify(label, series, tfidfS, paaSize, alphabetSize, windowSize,
                strategy);
        totalTestSample++;
      }
      totalPositiveTestsS = totalPositiveTestsS + positivesS;
    }
    double accuracyS = (double) totalPositiveTestsS / (double) totalTestSample;
    double errorS = 1.0d - accuracyS;
    long tfidfClassEndS = System.currentTimeMillis();

    StringBuffer sb = new StringBuffer();
    sb.append("cmprun ");
    sb.append(trainSize + ", ").append(testSize + ", ");
    sb.append(windowSize + ", ").append(paaSize + ", ").append(alphabetSize + ", ");
    sb.append(accuracy + ", ").append(error + ", ").append(accuracyS + ", ").append(errorS + ", ");
    
    sb.append(String.valueOf(tfidfEnd - tfidfStart) + ", ");
    sb.append(String.valueOf(tfidfEndS - tfidfEnd) + ", ");
    sb.append(String.valueOf(tfidfClassEnd - tfidfEndS) + ", ");
    sb.append(String.valueOf(tfidfClassEndS - tfidfClassEnd));

    System.out.println(sb.toString());
  }

  private static Map<String, List<double[]>> makeSet(int num) {

    // ticks - i.e. time
    int[] t = new int[128];
    for (int i = 0; i < 128; i++) {
      t[i] = i;
    }

    Map<String, List<double[]>> set = new HashMap<String, List<double[]>>();

    ArrayList<double[]> c = new ArrayList<double[]>();
    for (int i = 0; i < num; i++) {
      c.add(CBFGenerator.cylinder(t));
    }

    ArrayList<double[]> b = new ArrayList<double[]>();
    for (int i = 0; i < num; i++) {
      b.add(CBFGenerator.bell(t));
    }

    ArrayList<double[]> f = new ArrayList<double[]>();
    for (int i = 0; i < num; i++) {
      f.add(CBFGenerator.funnel(t));
    }

    set.put("1", c);
    set.put("2", b);
    set.put("3", f);

    return set;
  }

  private static void save(String fname, Map<String, ArrayList<double[]>> set) throws IOException {
    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(fname)));
    for (Entry<String, ArrayList<double[]>> e : set.entrySet()) {
      for (double[] a : e.getValue()) {
        bw.write(e.getKey()
            + " "
            + Arrays.toString(a).replace("[", "").replace("]", "").replaceAll(" ", "")
                .replace(",", " ") + "\n");
      }
    }
    bw.close();
  }

}
