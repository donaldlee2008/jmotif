package edu.hawaii.jmotif.performance.digits;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import cc.mallet.util.Randoms;
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
public class UCRdigitsWebProper extends UCRGenericClassifier {

  // data locations
  //
  private static final String TRAINING_DATA = "data/digits/digits_normalized_reduced_200.csv";
  private static final String TEST_DATA = "data/digits/test.csv";

  // SAX parameters to try
  //
  private static final int[][] params = { { 194, 15, 5, EXACT },};

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
    List<double[]> testData = readTestData(TEST_DATA);

    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(
        "data/digits/third_try_1000.csv")));
    bw.write("ImageId,Label\n");

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
      for (double[] series : testData) {

        WordBag test = TextUtils.seriesToWordBag("test", series, params[0]);

        // it is Cosine similarity,
        //
        // which ranges from 0.0 for the angle of 90 to 1.0 for the angle of 0
        // i.e. LARGES value is a SMALLEST distance
        double minDist = Double.MIN_VALUE;
        String className = "";

        double[] cosines = new double[tfidf.entrySet().size()];

        int index = 0;
        for (Entry<String, HashMap<String, Double>> e : tfidf.entrySet()) {

          double dist = TextUtils.cosineSimilarity(test, e.getValue());
          cosines[index] = dist;
          index++;

          if (dist > minDist) {
            className = e.getKey();
            minDist = dist;
          }

        }

        // sometimes, due to the VECTORs specific layout, all values are the same, NEED to take care
        boolean allEqual = true;
        double cosine = cosines[0];
        for (int i = 1; i < cosines.length; i++) {
          if (!(cosines[i] == cosine)) {
            allEqual = false;
          }
        }

        // report our findings
        if (!(allEqual)) {
          System.out.println(seriesCounter + ":" + className);
          bw.write(seriesCounter + "," + className + "\n");
        }
        else {
          long guess = Math.round(randoms.nextUniform(-0.49999, 9.49999));
          System.out.println(seriesCounter + ":" + guess);
          bw.write(seriesCounter + "," + guess + "\n");
        }

        seriesCounter++;
      }
    }
    bw.close();

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
