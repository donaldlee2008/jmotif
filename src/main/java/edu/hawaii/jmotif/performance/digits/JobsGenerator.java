package edu.hawaii.jmotif.performance.digits;

public class JobsGenerator {
  
  // Rscript --no-restore --no-save --verbose svm.R digits_reduced_1000.csv test.csv submission2.csv 0.025 2 0.019

  static final double[] cost = { 0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000 };
  static final double[] gamma = { 0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000 };
  // static final int[] degree = { 2, 3, 4, 5, 6, 7, 8, 9 };

  // static double[] cost = { 0.0232, 0.0235, 0.0238, 0.0242, 0.0245, 0.0248 };
  // static double[] gamma = { 0.019, 0.0192, 0.0195, 0.0197, 0.02 };
  static final int[] degree = { 2 };

  public static void main(String[] args) {

    for (double c : cost) {
      for (double g : gamma) {
        for (int d : degree) {
          StringBuffer sb = new StringBuffer();
          sb.append("Rscript --restore --no-save --verbose svm-optimize.R digits_reduced_400.csv digits_reduced_1000.csv ");
          sb.append(d + "_" + c + "_" + g + ".out ");
          sb.append(c + " " + d + " " + g);
          System.out.println(sb.toString());
        }
      }
    }

  }

}
