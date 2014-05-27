package edu.hawaii.jmotif.performance.digits;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import cc.mallet.util.Randoms;
import edu.hawaii.jmotif.performance.KNNStackEntry;
import edu.hawaii.jmotif.performance.UCRGenericClassifier;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;

/**
 * Helper-runner for test.
 * 
 * @author psenin
 * 
 */
public class VectorExplorer extends UCRGenericClassifier {

  // data locations
  //
  private static final String TRAINING_DATA = "data/digits/digits_reduced_400.csv";
  private static final String TEST_DATA = "data/digits/test.csv";

  // SAX parameters to try
  //
  private static final int[][] params = { { 177, 16, 3, NOREDUCTION }, };

  private static final Randoms randoms = new Randoms();

  /**
   * Runnable.
   * 
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    // making training and test collections
    //
    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(TRAINING_DATA);
    Map<String, List<double[]>> testData = UCRUtils.readUCRData(TEST_DATA);

    // iterate over parameters
    //
    for (int[] p : params) {

      // converting back from easy encoding
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
      List<WordBag> allBags = TextUtils.labeledSeries2WordBags(trainData, PAA_SIZE, ALPHABET_SIZE,
          WINDOW_SIZE, strategy);

      List<WordBag> bags = new ArrayList<WordBag>();

      WordBag others = new WordBag("other");
      for (WordBag bag : allBags) {
        if ("0".equalsIgnoreCase(bag.getLabel())) {
          bags.add(bag);
        }
        else if ("1".equalsIgnoreCase(bag.getLabel())) {
          bags.add(bag);
        }
        else {
          others.mergeWith(bag);
        }
      }
      bags.add(others);

      // getting TFIDF done
      HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);

      // for (int i = 0; i < 10; i++) {
      // for (int j = i + 1; j < 10; j++) {
      // double value = cosine(tfidf.get(String.valueOf(i)), tfidf.get(String.valueOf(j)));
      // System.out.println("distance " + i + ", " + j + ": " + value);
      // }
      // }

      int seriesCounter = 1;
      for (Entry<String, List<double[]>> te : testData.entrySet()) {

        String classId = te.getKey();

        for (double[] series : te.getValue()) {

          WordBag test = TextUtils.seriesToWordBag("test", series, params[0]);

          ArrayList<KNNStackEntry<String, Double>> cosines = new ArrayList<KNNStackEntry<String, Double>>();

          // get cosines computed
          for (Entry<String, HashMap<String, Double>> e : tfidf.entrySet()) {
            double dist = TextUtils.cosineSimilarity(test, e.getValue());
            cosines.add(new KNNStackEntry<String, Double>(e.getKey(), dist));
          }

          Collections.sort(cosines, new Comparator<KNNStackEntry<String, Double>>() {
            @Override
            public int compare(KNNStackEntry<String, Double> arg0,
                KNNStackEntry<String, Double> arg1) {
              return arg0.getValue().compareTo(arg1.getValue());
            }
          });

          // report our findings
          if (classId.equalsIgnoreCase(cosines.get(2).getKey())) {
            // System.out.println("correct: series of class " + classId + " classified as class "
            // + cosines.get(2).getKey() + ", distance " + cosines.get(2).getValue()
            // + ", second class: " + cosines.get(1).getKey() + ", distance: "
            // + cosines.get(1).getValue());
            System.out.println("1," + classId + "," + cosines.get(2).getKey() + ","
                + cosines.get(2).getValue() + cosines.get(1).getKey() + ","
                + cosines.get(1).getValue() + ",NA");
          }
          else {
            // System.out.println("incorrect: series of class " + classId + " classified as class "
            // + cosines.get(2).getKey() + ", distance " + cosines.get(2).getValue()
            // + ", second class: " + cosines.get(1).getKey() + ", distance: "
            // + cosines.get(1).getValue() + ", distance to correct class "
            // + getDistanceTo(classId, cosines));
            System.out.println("0," + classId + "," + cosines.get(2).getKey() + ","
                + cosines.get(2).getValue() + "," + cosines.get(1).getKey() + ","
                + cosines.get(1).getValue() + "," + getDistanceTo(classId, cosines));
          }

          seriesCounter++;
        }
      }
    }

  }

  private static double getDistanceTo(String classId,
      ArrayList<KNNStackEntry<String, Double>> cosines) {
    for (KNNStackEntry<String, Double> e : cosines) {
      if (classId.equalsIgnoreCase(e.getKey())) {
        return e.getValue();
      }
    }
    return -1.;
  }

  private static double cosine(HashMap<String, Double> data1, HashMap<String, Double> data2) {
    // sanity word order check
    if (!(data2.keySet().containsAll(data1.keySet()))
        || !(data2.keySet().size() == data1.keySet().size())) {
      throw new RuntimeException("COSINE SIMILARITY ERROR: word sets are different in length!");
    }

    double[] vector1 = new double[data1.size()];
    double[] vector2 = new double[data2.size()];

    int i = 0;
    for (String s : data1.keySet()) {
      vector1[i] = data1.get(s);
      vector2[i] = data2.get(s);
      i++;
    }

    double numerator = TextUtils.dotProduct(vector1, vector2);
    double denominator = TextUtils.magnitude(vector1) * TextUtils.magnitude(vector2);

    return numerator / denominator;
  }

  private static List<double[]> readTestData(String fileName) throws NumberFormatException,
      IOException {
    List<double[]> res = new ArrayList<double[]>();

    BufferedReader br = new BufferedReader(new FileReader(new File(fileName)));
    String line = "";
    while ((line = br.readLine()) != null) {

      if (line.trim().length() == 0) {
        continue;
      }

      String[] split = line.trim().split(",|\\s+");

      double[] series = new double[split.length];
      for (int i = 0; i < split.length; i++) {
        series[i] = Double.valueOf(split[i].trim()).doubleValue();
      }

      res.add(series);
    }

    br.close();
    return res;

  }

  private static Double parseValue(String string) {
    Double res = Double.NaN;
    try {
      Double r = Double.valueOf(string);
      res = r;
    }
    catch (NumberFormatException e) {
      assert true;
    }
    return res;
  }

}
