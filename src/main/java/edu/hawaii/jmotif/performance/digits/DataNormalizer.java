package edu.hawaii.jmotif.performance.digits;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.Arrays;
import edu.hawaii.jmotif.timeseries.TSUtils;

public class DataNormalizer {

  // data locations
  //
  private static String IN_DATA = "data/digits/test.csv";
  private static String OUT_DATA = "data/digits/test_normalized.csv";

  /**
   * Runnable.
   * 
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    if (args.length > 0) {
      IN_DATA = args[0];
      OUT_DATA = args[1];
    }

    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(OUT_DATA)));

    BufferedReader br = new BufferedReader(new FileReader(new File(IN_DATA)));

    String line = "";
    int counter = 0;
    while ((line = br.readLine()) != null) {

      if (line.trim().length() == 0) {
        continue;
      }

      String[] split = line.trim().split(",|\\s+");

      String label = split[0];

      double[] series = new double[split.length - 1];
      for (int i = 1; i < split.length; i++) {
        series[i - 1] = Double.valueOf(split[i].trim()).doubleValue();
      }

      double[] normalized = TSUtils.zNormalize(series);

      bw.write(label + " "
          + Arrays.toString(normalized).replace("[", "").replace("]", "").replace(",", "") + "\n");

      counter++;

      if (counter % 1000 == 0) {
        System.out.println("Processed " + counter);
      }
    }
    br.close();
    bw.close();

  }

}
