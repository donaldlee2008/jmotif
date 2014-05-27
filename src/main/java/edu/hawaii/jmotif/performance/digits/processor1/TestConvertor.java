package edu.hawaii.jmotif.performance.digits.processor1;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;

public class TestConvertor {

  private static final File folder = new File("data/digits/test_fiji_processed");
  private static final String OUT_DATA = "data/digits/test_resized.csv";

  /**
   * @param args
   * @throws IOException
   * @throws NumberFormatException
   * @throws TSException
   */
  public static void main(String[] args) throws NumberFormatException, IOException, TSException {

    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(OUT_DATA)));

    File[] listOfFiles = folder.listFiles();
    ArrayList<File> fnames = new ArrayList<File>();
    for (File f : listOfFiles) {
      fnames.add(f);
    }
    Collections.sort(fnames, new Comparator<File>() {
      @Override
      public int compare(File arg0, File arg1) {
        return arg0.getName().compareTo(arg1.getName());
      }
    });

    for (File f : fnames) {

      double[] line = readData(f);

      double[] normalized = TSUtils.zNormalize(line);

      bw.write(Arrays.toString(normalized).replace("[", "").replace("]", "").replace(",", "")
          + "\n");

    }
    bw.close();
  }

  private static double[] readData(File f) throws NumberFormatException, IOException {

    double[] res = new double[784];

    BufferedReader br = new BufferedReader(new FileReader(f));

    String line = "";
    int counter = 0;
    while ((line = br.readLine()) != null) {

      if (line.trim().length() == 0) {
        continue;
      }

      String[] split = line.trim().split(",|\\s+");

      for (int i = 0; i < split.length; i++) {
        res[counter] = Double.valueOf(split[i].trim()).doubleValue();
        counter++;
      }
    }

    br.close();
    return res;
  }

}
