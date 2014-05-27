package edu.hawaii.jmotif.performance.digits;

import java.awt.Point;
import java.util.ArrayList;
import java.util.Arrays;

public class MooreUtils {

  private static final int THRESHOLD = 10;
  private static final int STEP = 7;

  public static double[] seriesToCode(double[] series) {
    // System.out.println(" -> " + label + " : " + series.length + " : "
    // + Arrays.toString(series).replace("[", "").replace("]", ""));

    Integer[] chain = mooreNeighbor(series);

    ArrayList<Double> curve = new ArrayList<Double>();
    ArrayList<Double> curve2 = new ArrayList<Double>();
    for (int i = 0; i < chain.length; i++) {

      int[] forwardHist = null;
      int[] backwardHist = null;

      if (i >= STEP && i < chain.length - STEP) {
        forwardHist = histogram(Arrays.copyOfRange(chain, i, i + STEP));
        backwardHist = histogram(Arrays.copyOfRange(chain, i - STEP, i));
      }
      else if (i < STEP) {
        forwardHist = histogram(Arrays.copyOfRange(chain, i, i + STEP));
        backwardHist = histogram(glue(
            Arrays.copyOfRange(chain, chain.length - (STEP - i), chain.length),
            Arrays.copyOfRange(chain, 0, i)));
      }
      else if (i >= chain.length - STEP) {
        forwardHist = histogram(glue(Arrays.copyOfRange(chain, i, chain.length),
            Arrays.copyOfRange(chain, 0, STEP - (chain.length - i))));
        backwardHist = histogram(Arrays.copyOfRange(chain, i - STEP, i));
      }

      double roi = roInverse(forwardHist, backwardHist);
      curve.add(roi);

      double ro2 = buildRo2(roi, forwardHist, backwardHist);
      curve2.add(ro2);
    }

    double[] res = new double[curve2.size()];
    for (int i = 0; i < curve2.size(); i++) {
      res[i] = curve2.get(i);
    }

    return res;

  }

  private static Integer[] glue(Integer[] arr1, Integer[] arr2) {
    Integer[] res = new Integer[arr1.length + arr2.length];
    for (int i = 0; i < arr1.length; i++) {
      res[i] = arr1[i];
    }
    for (int i = 0; i < arr2.length; i++) {
      res[i + arr1.length] = arr2[i];
    }
    return res;
  }

  private static int[] toArray(String line) {
    int[] res = new int[728];
    String[] split = line.split("\\s+");
    for (int i = 0; i < 728; i++) {
      res[i] = Integer.valueOf(split[i + 1]);
    }
    return res;
  }

  private static double buildRo2(double roi, int[] forwardHist, int[] backwardHist) {
    int modF = mod(forwardHist);
    int modG = mod(backwardHist);

    int i1 = (modG + 1) % 8;
    int i2 = (modG + 3) % 8;

    int i3 = (modG - 1) % 8;
    int i4 = (modG - 3) % 8;

    int sign = 1;
    // if (Math.min(i1, i2) <= modF && modF <= Math.max(i1, i2)) {
    // sign = 1;
    // }

    if (modF == modG) {
      return 0;
    }

    if (Math.min(i3, i4) <= modF && modF <= Math.max(i3, i4)) {
      sign = -1;
    }

    return Math.abs(roi - 1) * sign;
  }

  private static int mod(int[] hist) {
    int resDirection = -1;
    int maxVal = -1;
    for (int i = 0; i < hist.length; i++) {
      if (hist[i] > maxVal) {
        resDirection = i;
        maxVal = hist[i];
      }
    }
    return resDirection;
  }

  private static double roInverse(int[] forwardHist, int[] backwardHist) {

    double meanForward = mean(forwardHist);
    double meanBackward = mean(backwardHist);

    double up = 0.;
    double lowLeft = 0.;
    double lowRight = 0.;

    for (int i = 0; i < 8; i++) {
      up = up + (forwardHist[i] - meanForward) * (backwardHist[i] - meanBackward);
      lowLeft = lowLeft + (forwardHist[i] - meanForward) * (forwardHist[i] - meanForward);
      lowRight = lowRight + (backwardHist[i] - meanBackward) * (backwardHist[i] - meanBackward);
    }

    return up / Math.sqrt(lowLeft * lowRight);
  }

  private static double mean(int[] forwardHist) {
    double res = 0.;
    for (int i = 0; i < forwardHist.length; i++) {
      res = res + forwardHist[i];
    }
    return res / (double) forwardHist.length;
  }

  private static int[] histogram(Integer[] copyOfRange) {
    int[] res = new int[8];
    for (int i = 0; i < copyOfRange.length; i++) {
      res[copyOfRange[i]]++;
    }
    return res;
  }

  public static Integer[] mooreNeighbor(double[] series) {

    int[][] matrix = new int[28][28];
    for (int i = 0; i < series.length; i++) {
      int row = i % 28;
      int col = i / 28;

      if (series[i] < (double) THRESHOLD) {
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

    ArrayList<Integer> chainCode = null;
    int chainCounter = 0;
    do {

      Point start = new Point();// starting point
      Point prev_start = new Point();// prev starting point
      Point prev = new Point();
      Point p = new Point();// current point

      int i = 0;
      int j = 0;

      // find the first point
      int[][] res = new int[28][28]; // resulting figure - i.e. contour
      chainCode = new ArrayList<Integer>(); // resulting chain code
      for (i = 0; i < 28; i++) {
        for (j = 27; j >= 0; j--)
          if (matrix[i][j] == 1) {
            prev_start.x = prev.x = i;
            prev_start.y = prev.y = j + 1;
            start.x = p.x = i;
            p.y = start.y = j;
            // System.out.println(p.x + " " + p.y + "\t" + prev.x + " " + prev.y);
            res[i][j] = 1;
            break;
          }
        if (j >= 0)
          break;
      }

      /** cautam marginea desenului pana nu am ajuns in punctul de start din acelasi predecesor */
      do {
        int direction = makeNextStep(matrix, p, prev);
        chainCode.add(direction);

        // System.out.println(p.x + " " + p.y + "\t" + prev.x + " " + prev.y);
        res[p.x][p.y] = 1;

        if ((p.x == start.x && p.y == start.y)
            && (prev.x != prev_start.x || prev.y != prev_start.y) && direction == 6) {
          prev.x = p.x;
          prev.y = p.y + 1;
        }

      }
      while (p.x != start.x || p.y != start.y || prev.x != prev_start.x || prev.y != prev_start.y);

      /*
       * lista1.clear(); lista2.clear();
       */
      // System.out.println("exit");

      chainCounter++;
      matrix = rotate(matrix);
      if (chainCounter > 1) {
        System.out.println("rotated  ");
      }
    }
    while (chainCode.size() < 30 && chainCounter < 4);

    Integer[] chain = chainCode.toArray(new Integer[chainCode.size()]);
    return chain;

  }

  private static int sum(int[] t) {
    int res = 0;
    for (int i = 0; i < t.length; i++) {
      res = res + t[i];
    }
    return res;
  }

  /**
   * Makes a next step from previous point to the next.
   * 
   * @param pane the picture pane.
   * @param next next point.
   * @param prev previous point.
   * @return the chosen direction - i.e. the chain code.
   */
  private static int makeNextStep(int[][] pane, Point next, Point prev) {
    int t[] = new int[8];
    int start = 0, i = 0;
    if (next.x == 0 && next.y != 0 && next.y != 27) {
      t[0] = t[6] = t[7] = 0;
      t[1] = pane[next.x][next.y - 1];
      t[2] = pane[next.x + 1][next.y - 1];
      t[3] = pane[next.x + 1][next.y];
      t[4] = pane[next.x + 1][next.y + 1];
      t[5] = pane[next.x][next.y + 1];
    }
    else if (next.x == 27 && next.y != 0 && next.y != 27) {
      t[2] = t[3] = t[4] = 0;
      t[0] = pane[next.x - 1][next.y - 1];
      t[1] = pane[next.x][next.y - 1];
      t[5] = pane[next.x][next.y + 1];
      t[6] = pane[next.x - 1][next.y + 1];
      t[7] = pane[next.x - 1][next.y];
    }
    else if (next.y == 0 && next.x != 0 && next.x != 27) {
      t[0] = t[1] = t[2] = 0;
      t[3] = pane[next.x + 1][next.y];
      t[4] = pane[next.x + 1][next.y + 1];
      t[5] = pane[next.x][next.y + 1];
      t[6] = pane[next.x - 1][next.y + 1];
      t[7] = pane[next.x - 1][next.y];
    }
    else if (next.y == 27 && next.x != 0 && next.x != 27) {
      t[6] = t[5] = t[4] = 0;
      t[0] = pane[next.x - 1][next.y - 1];
      t[1] = pane[next.x][next.y - 1];
      t[2] = pane[next.x + 1][next.y - 1];
      t[3] = pane[next.x + 1][next.y];
      t[7] = pane[next.x - 1][next.y];
    }
    else if (next.x == 0 && next.y == 0) {
      t[0] = t[6] = t[7] = t[2] = t[1] = 0;
      t[3] = pane[next.x + 1][next.y];
      t[4] = pane[next.x + 1][next.y + 1];
      t[5] = pane[next.x][next.y + 1];
    }
    else if (next.x == 0 && next.y == 27) {
      t[0] = t[6] = t[7] = t[5] = t[4] = 0;
      t[1] = pane[next.x][next.y - 1];
      t[2] = pane[next.x + 1][next.y - 1];
      t[3] = pane[next.x + 1][next.y];
    }
    else if (next.x == 27 && next.y == 0) {
      t[0] = t[1] = t[2] = t[3] = t[4] = 0;
      t[5] = pane[next.x][next.y + 1];
      t[6] = pane[next.x - 1][next.y + 1];
      t[7] = pane[next.x - 1][next.y];
    }
    else if (next.x == 27 && next.y == 27) {
      t[6] = t[5] = t[4] = t[2] = t[3] = 0;
      t[0] = pane[next.x - 1][next.y - 1];
      t[1] = pane[next.x][next.y - 1];
      t[7] = pane[next.x - 1][next.y];
    }
    else {
      t[0] = pane[next.x - 1][next.y - 1];
      t[1] = pane[next.x][next.y - 1];
      t[2] = pane[next.x + 1][next.y - 1];
      t[3] = pane[next.x + 1][next.y];
      t[4] = pane[next.x + 1][next.y + 1];
      t[5] = pane[next.x][next.y + 1];
      t[6] = pane[next.x - 1][next.y + 1];
      t[7] = pane[next.x - 1][next.y];
    }
    if (prev.x == next.x - 1 && prev.y == next.y - 1)
      start = 0;
    if (prev.x == next.x && prev.y == next.y - 1)
      start = 1;
    if (prev.x == next.x + 1 && prev.y == next.y - 1)
      start = 2;
    if (prev.x == next.x + 1 && prev.y == next.y)
      start = 3;
    if (prev.x == next.x + 1 && prev.y == next.y + 1)
      start = 4;
    if (prev.x == next.x && prev.y == next.y + 1)
      start = 5;
    if (prev.x == next.x - 1 && prev.y == next.y + 1)
      start = 6;
    if (prev.x == next.x - 1 && prev.y == next.y)
      start = 7;
    for (i = start + 1; i < 8; i++) {
      if (t[i] == 1)
        break;
    }
    if (i == 8)
      for (i = 0; i <= start; i++)
        if (t[i] == 1)
          break;
    /*
     * prev.x=next.x; prev.y=next.y;
     */
    if (i == 0) {
      prev.x = next.x - 1;
      prev.y = next.y;
      next.x = next.x - 1;
      next.y = next.y - 1;
    }
    if (i == 1) {
      prev.x = next.x - 1;
      prev.y = next.y - 1;
      next.x = next.x;
      next.y = next.y - 1;
    }
    if (i == 2) {
      prev.x = next.x;
      prev.y = next.y - 1;
      next.x = next.x + 1;
      next.y = next.y - 1;
    }
    if (i == 3) {
      prev.x = next.x + 1;
      prev.y = next.y - 1;
      next.x = next.x + 1;
      next.y = next.y;
    }
    if (i == 4) {
      prev.x = next.x + 1;
      prev.y = next.y;
      next.x = next.x + 1;
      next.y = next.y + 1;
    }
    if (i == 5) {
      prev.x = next.x + 1;
      prev.y = next.y + 1;
      next.x = next.x;
      next.y = next.y + 1;
    }
    if (i == 6) {
      prev.x = next.x;
      prev.y = next.y + 1;
      next.x = next.x - 1;
      next.y = next.y + 1;
    }
    if (i == 7) {
      prev.x = next.x - 1;
      prev.y = next.y + 1;
      next.x = next.x - 1;
      next.y = next.y;
    }
    return i;
  }

  private static int[][] rotate(int[][] mat) {
    int n = mat.length;
    int m = mat[0].length;
    int transpose[][] = new int[n][m];
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < m; j++) {
        transpose[i][j] = mat[j][m - i - 1];
      }
    }
    return transpose;
  }

}
