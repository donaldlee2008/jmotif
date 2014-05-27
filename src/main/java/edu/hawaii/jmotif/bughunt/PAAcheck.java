package edu.hawaii.jmotif.bughunt;

import java.util.Arrays;
import edu.hawaii.jmotif.algorithm.MatrixFactory;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;

public class PAAcheck {

  private static final double[] series = { 2.0, 3.0, 1.0, 1.0, 10.0, 10.0, 8.0, 12.0, 6.0, 5.0,
      15.0, 14.0, 7.0, 3.0, 9.0 };
  private static final String CR = "\n";
  private static final int paaSize = 9;

  /**
   * @param args
   * @throws TSException
   */
  public static void main(String[] args) throws TSException {

    System.out.print("Data: " + Arrays.toString(series) + CR);

    double[] paa = TSUtils.paa(series, paaSize);

    System.out.print("PAA to 9 points: " + Arrays.toString(paa) + CR + CR);

    double[][] vals = TSUtils.asMatrix(series);
    double[][] tmp = new double[paaSize][series.length];
    for (int i = 0; i < paaSize; i++) {
      for (int j = 0; j < series.length; j++) {
        tmp[i][j] = vals[0][j];
      }
    }
    double[][] expandedSS = MatrixFactory.reshape(tmp, 1, series.length * paaSize);
    double[][] res = MatrixFactory.reshape(expandedSS, series.length, paaSize);

    String mtx = MatrixFactory.toString(res);

    System.out.print("PAA matrix: " + mtx + CR + CR);

    NormalAlphabet na = new NormalAlphabet();

    char[] str = TSUtils.ts2String(TSUtils.paa(TSUtils.zNormalize(series), 9), na.getCuts(8));

    System.out.print("SAX: " + String.valueOf(str) + CR + CR);
  }

}
