package edu.hawaii.jmotif.performance.digits.normalizer;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.Arrays;
import edu.hawaii.jmotif.timeseries.TSUtils;

public class TestNormalizer {

  // data locations
  //
  private static final String IN_DATA = "data/digits/test.csv";
  private static final String OUT_DATA = "data/digits/test_normalized.csv";

  /**
   * Runnable.
   * 
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(OUT_DATA)));

    BufferedReader br = new BufferedReader(new FileReader(new File(IN_DATA)));

    String line = "";
    int counter = 0;
    while ((line = br.readLine()) != null) {

      if (line.trim().length() == 0) {
        continue;
      }
      //ImageId,Label

      String[] split = line.trim().split(",|\\s+");

      double[] series = new double[split.length];
      for (int i = 0; i < split.length; i++) {
        series[i] = Double.valueOf(split[i].trim()).doubleValue();
      }

      double[] normalized = TSUtils.zNormalize(series);

      bw.write(Arrays.toString(normalized).replace("[", "").replace("]", "").replace(",", "")
          + "\n");

      counter++;

      if (counter % 1000 == 0) {
        System.out.println("Processed " + counter);
      }
    }
    br.close();
    bw.close();

  }

}
