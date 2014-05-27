package edu.hawaii.jmotif.performance.digits.processor2;

import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import javax.imageio.ImageIO;

public class TrainCropper {

  // data locations
  //
  private static final String TRAINING_DATA = "data/digits/train.csv";
  private static final int THRESHOLD = 0;

  /**
   * Runnable.
   * 
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    Map<String, double[]> trainData = readTrainData(TRAINING_DATA);

    for (Entry<String, double[]> e : trainData.entrySet()) {

      // System.out.println(e.getKey() + ": " + Arrays.toString(e.getValue()));
      // if (e.getKey().equalsIgnoreCase("1_87")) {
      // System.out.println(Arrays.toString(e.getValue()));
      // }

      // matrix
      int[][] mat = new int[28][28];
      for (int i = 0; i < e.getValue().length; i++) {
        int row = i / 28;
        int col = i % 28;
        int value = (int) e.getValue()[i];
        if (value > THRESHOLD) {
          mat[row][col] = (int) e.getValue()[i];
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

      ImageIO.write(img, "png", new File("data/digits/train/" + e.getKey() + "_cropped.png"));

    }

  }

  private static Map<String, double[]> readTrainData(String fileName) throws NumberFormatException,
      IOException {

    Map<String, double[]> res = new HashMap<String, double[]>();

    BufferedReader br = new BufferedReader(new FileReader(new File(fileName)));

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

      res.put(label + "_" + String.valueOf(counter), series);

      counter++;
    }

    br.close();
    return res;
  }

}
