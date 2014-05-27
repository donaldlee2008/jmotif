package edu.hawaii.jmotif.performance.digits;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays;

public class RawToDespeckled {

  private static final int THRESHOLD = 4;
  private static final int STEP = 8;

  /**
   * @param args
   * @throws IOException
   */
  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new FileReader(new File(
        "data/digits/digits_reduced_50.csv")));

    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(
        "data/digits/digits_despeckled_50.csv")));

    String line = null;
    int counter = 0;
    while ((line = br.readLine()) != null) {
      if (!(line.isEmpty())) {

        String label = line.split("\\s+")[0];
        int[] series = toArray(line);

        int[] dat = despeckle(series);

        bw.write(label + " "
            + Arrays.toString(dat).replace("[", "").replace("]", "").replace(", ", " ") + "\n");

        counter++;

      }

    }
    bw.close();
    br.close();
  }

  private static int[] toArray(String line) {
    int[] res = new int[728];
    String[] split = line.split("\\s+");
    for (int i = 0; i < 728; i++) {
      res[i] = Integer.valueOf(split[i + 1]);
    }
    return res;
  }

  public static int[] despeckle(int[] dataString) {

    int[][] matrix = new int[28][28];
    for (int i = 0; i < dataString.length; i++) {
      int row = i % 28;
      int col = i / 28;

      if (Integer.valueOf(dataString[i]).intValue() < THRESHOLD) {
        matrix[row][col] = 0;
      }
      else {
        matrix[row][col] = 1;
      }

      // System.out.print(matrix[row][col] + ",");
    }

    // despecle
    int n = matrix.length;
    int m = matrix[0].length;
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < m; j++) {
        int dot = matrix[i][j];
        if (dot == 1) {
          int t[] = new int[8];
          if (i == 0 && j != 0 && j != 27) {
            t[0] = t[6] = t[7] = 0;
            t[1] = matrix[i][j - 1];
            t[2] = matrix[i + 1][j - 1];
            t[3] = matrix[i + 1][j];
            t[4] = matrix[i + 1][j + 1];
            t[5] = matrix[i][j + 1];
          }
          else if (i == 27 && j != 0 && j != 27) {
            t[2] = t[3] = t[4] = 0;
            t[0] = matrix[i - 1][j - 1];
            t[1] = matrix[i][j - 1];
            t[5] = matrix[i][j + 1];
            t[6] = matrix[i - 1][j + 1];
            t[7] = matrix[i - 1][j];
          }
          else if (j == 0 && i != 0 && i != 27) {
            t[0] = t[1] = t[2] = 0;
            t[3] = matrix[i + 1][j];
            t[4] = matrix[i + 1][j + 1];
            t[5] = matrix[i][j + 1];
            t[6] = matrix[i - 1][j + 1];
            t[7] = matrix[i - 1][j];
          }
          else if (j == 27 && i != 0 && i != 27) {
            t[6] = t[5] = t[4] = 0;
            t[0] = matrix[i - 1][j - 1];
            t[1] = matrix[i][j - 1];
            t[2] = matrix[i + 1][j - 1];
            t[3] = matrix[i + 1][j];
            t[7] = matrix[i - 1][j];
          }
          else if (i == 0 && j == 0) {
            t[0] = t[6] = t[7] = t[2] = t[1] = 0;
            t[3] = matrix[i + 1][j];
            t[4] = matrix[i + 1][j + 1];
            t[5] = matrix[i][j + 1];
          }
          else if (i == 0 && j == 27) {
            t[0] = t[6] = t[7] = t[5] = t[4] = 0;
            t[1] = matrix[i][j - 1];
            t[2] = matrix[i + 1][j - 1];
            t[3] = matrix[i + 1][j];
          }
          else if (i == 27 && j == 0) {
            t[0] = t[1] = t[2] = t[3] = t[4] = 0;
            t[5] = matrix[i][j + 1];
            t[6] = matrix[i - 1][j + 1];
            t[7] = matrix[i - 1][j];
          }
          else if (i == 27 && j == 27) {
            t[6] = t[5] = t[4] = t[2] = t[3] = 0;
            t[0] = matrix[i - 1][j - 1];
            t[1] = matrix[i][j - 1];
            t[7] = matrix[i - 1][j];
          }
          else {
            t[0] = matrix[i - 1][j - 1];
            t[1] = matrix[i][j - 1];
            t[2] = matrix[i + 1][j - 1];
            t[3] = matrix[i + 1][j];
            t[4] = matrix[i + 1][j + 1];
            t[5] = matrix[i][j + 1];
            t[6] = matrix[i - 1][j + 1];
            t[7] = matrix[i - 1][j];
          }
          if (sum(t) <= 1) {
            matrix[i][j] = 0;
          }
        }
      }
    }

    int[] res = new int[784];

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < m; j++) {
        res[i * 28 + j] = matrix[j][i];
      }
    }

    return res;
  }

  private static int sum(int[] t) {
    int res = 0;
    for (int i = 0; i < t.length; i++) {
      res = res + t[i];
    }
    return res;
  }

}
