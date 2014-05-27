package edu.hawaii.jmotif.performance.digits.processor2;

import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
import javax.imageio.ImageIO;

public class TestCropper {

  // data locations
  private static final String TEST_DATA = "data/digits/test.csv";

  private static final DecimalFormat myFormatter = new DecimalFormat("000000");

  private static final int THRESHOLD = 0;

  /**
   * Runnable.
   * 
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    // Map<String, double[]> trainData = readTrainData(TRAINING_DATA);
    List<double[]> testData = readTestData(TEST_DATA);

    // for (Entry<String, double[]> e : trainData.entrySet()) {

    int counter = 0;
    int minWidth = 1000;
    String minwidthName = "";
    for (double[] e : testData) {
      // System.out.println(e.getKey() + ": " + Arrays.toString(e.getValue()));
      // if (e.getKey().equalsIgnoreCase("1_87")) {
      // System.out.println(Arrays.toString(e.getValue()));
      // }

      // matrix
      int[][] mat = new int[28][28];
      for (int i = 0; i < e.length; i++) {
        int row = i / 28;
        int col = i % 28;
        int value = (int) e[i];
        if (value > THRESHOLD) {
          mat[row][col] = (int) e[i];
        }
        else {
          mat[row][col] = 0;
        }
      }

      // write
      //
      BufferedImage img = new BufferedImage(28, 28, BufferedImage.TYPE_INT_RGB);

      for (int x = 0; x < 28; ++x) {
        for (int y = 0; y < 28; ++y) {
          int grayscale = mat[y][x];
          int colorValue = grayscale | grayscale << 8 | grayscale << 16;
          img.setRGB(x, y, colorValue);
        }

      }

      ImageIO.write(img, "png", new File("data/digits/test/" + myFormatter.format(counter)
          + "_cropped.png"));

      counter++;
    }

  }

  private static ArrayList<double[]> readTestData(String fileName) throws NumberFormatException,
      IOException {
    ArrayList<double[]> res = new ArrayList<double[]>();

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
}
