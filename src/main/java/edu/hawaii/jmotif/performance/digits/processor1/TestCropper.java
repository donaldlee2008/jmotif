package edu.hawaii.jmotif.performance.digits.processor1;

import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import javax.imageio.ImageIO;

public class TestCropper {

  // data locations
  private static final String TEST_DATA = "data/digits/test.csv";

  private static final DecimalFormat myFormatter = new DecimalFormat("000000");

  private static final int THRESHOLD = 10;

  private static final String OUT_PREFIX = "data/digits/test/";
  private static final Object SPACE = " ";

  /**
   * Runnable.
   * 
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    // Map<String, double[]> trainData = readTrainData(TRAINING_DATA);
    List<double[]> testData = readTestData(TEST_DATA);

    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(OUT_PREFIX + "metadata.csv")));

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

      ImageIO.write(img, "png", new File("output_raw.png"));

      // get it cropped
      int[] cols = new int[28];
      int[] rows = new int[28];

      for (int i = 0; i < 28; i++) {
        for (int j = 0; j < 28; j++) {
          if (mat[i][j] > 0) {
            rows[i] = 1;
            cols[j] = 1;
          }
        }
      }

      // regions by x and y
      List<Interval> regionsX = getRegions(cols);
      List<Interval> regionsY = getRegions(rows);

      // get those with single intervals separated
      if (regionsX.size() == 1 && regionsY.size() == 1) {
        int ystart = regionsY.get(0).getStart();
        int yend = regionsY.get(0).getEnd();
        int xstart = regionsX.get(0).getStart();
        int xend = regionsX.get(0).getEnd();
        int croppedRows = yend - ystart + 1;
        int croppedCols = xend - xstart + 1;
        int[][] crop = new int[croppedRows][croppedCols];
        for (int i = 0; i < croppedRows; i++) {
          for (int j = 0; j < croppedCols; j++) {
            crop[i][j] = mat[i + ystart][j + xstart];
          }
        }

        // write
        //
        img = new BufferedImage(croppedCols, croppedRows, BufferedImage.TYPE_INT_RGB);

        for (int x = 0; x < croppedCols; ++x) {
          for (int y = 0; y < croppedRows; ++y) {
            int grayscale = crop[y][x];
            int colorValue = grayscale | grayscale << 8 | grayscale << 16;
            img.setRGB(x, y, colorValue);
          }

        }

        ImageIO.write(img, "png", new File("data/digits/test/" + myFormatter.format(counter)
            + "_cropped.png"));

        bw.write(myFormatter.format(counter) + " " + toMetadata(crop) + "\n");

      }
      else {

        // sort by size
        Collections.sort(regionsX, new Comparator<Interval>() {
          @Override
          public int compare(Interval arg0, Interval arg1) {
            return Integer.valueOf(arg0.length()).compareTo(Integer.valueOf(arg1.length()));
          }
        });
        Collections.sort(regionsY, new Comparator<Interval>() {
          @Override
          public int compare(Interval arg0, Interval arg1) {
            return Integer.valueOf(arg0.length()).compareTo(Integer.valueOf(arg1.length()));
          }
        });

        // remove those tiny pixel ones
        while (regionsX.size() > 1 && regionsX.get(0).length() < 5) {
          // get the size of a feature here by Y
          int minY = 27;
          int maxY = 0;
          for (int i = 0; i < 28; i++) {
            for (int j = 0; j < regionsX.get(0).length(); j++) {
              if (mat[i][regionsX.get(0).getStart() + j] == 1) {
                if (i < minY) {
                  minY = i;
                }
                if (i > maxY) {
                  maxY = i;
                }
              }
            }
          }
          if ((maxY - minY) < 8) {
            regionsX.remove(0);
          }
        }

        while (regionsY.size() > 1 && regionsY.get(0).length() < 5) {
          // get the size of a feature here by X
          int minX = 27;
          int maxX = 0;
          for (int i = 0; i < regionsY.get(0).length(); i++) {
            for (int j = 0; j < 28; j++) {
              if (mat[regionsY.get(0).getStart() + i][j] == 1) {
                if (j < minX) {
                  minX = j;
                }
                if (j > maxX) {
                  maxX = j;
                }
              }
            }
          }
          if ((maxX - minX) < 8) {
            regionsY.remove(0);
          }

        }

        // plot now, but first resort by start
        Collections.sort(regionsX, new Comparator<Interval>() {
          @Override
          public int compare(Interval arg0, Interval arg1) {
            return Integer.valueOf(arg0.getStart()).compareTo(Integer.valueOf(arg1.getStart()));
          }
        });
        Collections.sort(regionsY, new Comparator<Interval>() {
          @Override
          public int compare(Interval arg0, Interval arg1) {
            return Integer.valueOf(arg0.getStart()).compareTo(Integer.valueOf(arg1.getStart()));
          }
        });

        int ystart = regionsY.get(0).getStart();
        int yend = regionsY.get(regionsY.size() - 1).getEnd();
        int xstart = regionsX.get(0).getStart();
        int xend = regionsX.get(regionsX.size() - 1).getEnd();
        int croppedRows = yend - ystart + 1;
        int croppedCols = xend - xstart + 1;
        if (croppedRows < 0 || croppedCols < 0) {
          System.out.println("gotcha");
        }
        if (croppedRows < 7) {
          ystart = ystart - 2;
          yend = yend + 2;
          croppedRows = yend - ystart + 1;
          if (minWidth > croppedRows) {
            minWidth = croppedRows;
            minwidthName = "data/digits/test/" + myFormatter.format(counter) + "_cropped.png";
          }
        }
        int[][] crop = new int[croppedRows][croppedCols];
        for (int i = 0; i < croppedRows; i++) {
          for (int j = 0; j < croppedCols; j++) {
            crop[i][j] = mat[i + ystart][j + xstart];
          }
        }

        // write
        //
        img = new BufferedImage(croppedCols, croppedRows, BufferedImage.TYPE_INT_RGB);

        for (int x = 0; x < croppedCols; ++x) {
          for (int y = 0; y < croppedRows; ++y) {
            int grayscale = crop[y][x];
            int colorValue = grayscale | grayscale << 8 | grayscale << 16;
            img.setRGB(x, y, colorValue);
          }

        }

        ImageIO.write(img, "png", new File("data/digits/test/" + myFormatter.format(counter)
            + "_cropped.png"));

        bw.write(myFormatter.format(counter) + " " + toMetadata(crop) + "\n");

      }

      counter++;
    }

    bw.close();

  }

  private static List<Interval> getRegions(int[] rows) {
    List<Interval> res = new ArrayList<Interval>();

    int oldI = 0;
    int oldVal = rows[oldI];

    boolean isBackground = true;
    if (oldVal > 0) {
      isBackground = false;
    }

    for (int i = 1; i < rows.length; i++) {

      if (oldVal != rows[i]) {

        if (rows[i] == 0) {
          if (!(isBackground)) {
            res.add(new Interval(oldI, i));
          }
          isBackground = true;
        }
        else {
          isBackground = false;
          oldI = i;
        }
        oldVal = rows[i];
      }
    }

    // special case
    if (rows[rows.length - 1] == 1 && !(isBackground)) {
      res.add(new Interval(oldI, rows.length - 1));
    }

    return res;
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

  private static String toMetadata(int[][] crop) {

    int meta1 = crop.length;
    int meta2 = crop[0].length;

    // three horizontal cuts
    List<Interval> horizontalCut1 = getRegions(Arrays.copyOf(crop[meta1 / 4],
        crop[meta1 / 4].length));
    List<Interval> horizontalCut2 = getRegions(Arrays.copyOf(crop[(meta1 / 4) * 2],
        crop[(meta1 / 4) * 2].length));
    List<Interval> horizontalCut3 = getRegions(Arrays.copyOf(crop[(meta1 / 4) * 3],
        crop[(meta1 / 4) * 3].length));

    // three vertivcal cuts
    List<Interval> verticalCut1 = getRegions(extractCol(crop, meta2 / 4));
    List<Interval> verticalCut2 = getRegions(extractCol(crop, (meta2 / 4) * 2));
    List<Interval> verticalCut3 = getRegions(extractCol(crop, (meta2 / 4) * 3));

    StringBuffer sb = new StringBuffer();
    sb.append(meta1).append(SPACE).append(meta2).append(SPACE);
    sb.append(horizontalCut1.size()).append(SPACE).append(horizontalCut2.size()).append(SPACE)
        .append(horizontalCut3.size()).append(SPACE);
    sb.append(verticalCut1.size()).append(SPACE).append(verticalCut2.size()).append(SPACE)
        .append(verticalCut3.size());
    return sb.toString();
  }

  private static int[] extractCol(int[][] crop, int j) {
    int[] res = new int[crop.length];
    for (int i = 0; i < crop.length; i++) {
      res[i] = crop[i][j];
    }
    return res;
  }

}
