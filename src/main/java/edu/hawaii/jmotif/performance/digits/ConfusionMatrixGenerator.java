package edu.hawaii.jmotif.performance.digits;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
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
public class ConfusionMatrixGenerator extends UCRGenericClassifier {

  // data locations
  //
  private static final String TRAINING_DATA = "data/digits/digits_reduced_1000.csv";
  private static final String TEST_DATA = "data/digits/digits_train.txt";

  // private static final String TRAINING_DATA = "data/digits/digits_reduced_50.csv";
  // private static final String TEST_DATA = "data/digits/digits_reduced_50.csv";

  // SAX parameters to try
  //
  private static final int[][] params = { { 177, 16, 3, NOREDUCTION }, };

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

    HashMap<String, HashMap<String, Integer>> confusionMatrix = new HashMap<String, HashMap<String, Integer>>();
    for (Integer i = 0; i < 10; i++) {
      HashMap<String, Integer> map = new HashMap<String, Integer>();
      for (Integer k = 0; k < 10; k++) {
        map.put(String.valueOf(k), 0);
      }
      confusionMatrix.put(String.valueOf(i), map);
    }

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
      List<WordBag> bags = TextUtils.labeledSeries2WordBags(trainData, PAA_SIZE, ALPHABET_SIZE,
          WINDOW_SIZE, strategy);

      // getting TFIDF done
      HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);

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
          if (classId.equalsIgnoreCase(cosines.get(9).getKey())) {
            System.out.println("correct: series of class " + classId + " classified as class "
                + cosines.get(9).getKey() + ", distance " + cosines.get(9).getValue()
                + ", second class: " + cosines.get(8).getKey() + ", distance: "
                + cosines.get(8).getValue());
          }
          else {
            System.out.println("incorrect: series of class " + classId + " classified as class "
                + cosines.get(9).getKey() + ", distance " + cosines.get(9).getValue()
                + ", second class: " + cosines.get(8).getKey() + ", distance: "
                + cosines.get(8).getValue() + ", distance to correct class "
                + getDistanceTo(classId, cosines));
            Integer oldCounter = confusionMatrix.get(classId).get(cosines.get(9).getKey());
            confusionMatrix.get(classId).put(cosines.get(9).getKey(), oldCounter + 1);
          }

          seriesCounter++;
        }
      }
    }

    System.out.println("Confusion data :");
    for (Integer i = 0; i < 10; i++) {
      HashMap<String, Integer> map = confusionMatrix.get(String.valueOf(i));
      System.out.print(i + ",");
      for (Integer k = 0; k < 10; k++) {
        System.out.print(map.get(String.valueOf(k)) + ",");
      }
      System.out.println();
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

}
