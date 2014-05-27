package edu.hawaii.jmotif.performance.digits.processor1;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;

public class TrainConvertor {

  private static final File folder = new File("data/digits/train_fiji_processed");
  
  private static final String OUT_DATA = "data/digits/train_resized.csv";

  /**
   * @param args
   * @throws IOException
   * @throws NumberFormatException
   * @throws TSException
   */
  public static void main(String[] args) throws NumberFormatException, IOException, TSException {

    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(OUT_DATA)));

    File[] listOfFiles = folder.listFiles();
    for (File f : listOfFiles) {

      String fName = f.getName();
      double[] line = readData(f);

      double[] normalized = TSUtils.zNormalize(line);

      bw.write(fName.substring(0, fName.indexOf("_")) + " "
          + Arrays.toString(normalized).replace("[", "").replace("]", "").replace(",", "") + "\n");

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
