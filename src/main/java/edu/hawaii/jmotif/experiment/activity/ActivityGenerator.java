package edu.hawaii.jmotif.experiment.activity;

import cc.mallet.util.Randoms;

public class ActivityGenerator {

  private static final double STDEV = 0.0001;
  private static final double IDENT = 2d;
  private static Randoms randoms;

  static {
    randoms = new Randoms();
  }

  public static double[] threePeriods(int seriesSpan, int[] js) {

    double[] res = new double[seriesSpan];

    // int break1start = Double.valueOf(randoms.nextUniform(0d, (double) activitySpan)).intValue();
    int total = 0;
    for (int i : js) {
      total = total + i;
    }

    int break1length = Double.valueOf(
        randoms.nextUniform(0, (double) seriesSpan - (total + IDENT * 2 + IDENT * 2))).intValue();
    // IDENT*2 - right and left idents
    // IDENT*2 - idents between peaks

    int break2length = Double.valueOf(
        randoms.nextUniform(0, (double) seriesSpan - (total + break1length + IDENT * 2 + IDENT)))
        .intValue();

    int start = Double.valueOf(
        randoms.nextUniform(IDENT, (double) seriesSpan
            - (total + break1length + break2length + IDENT * 2 + IDENT * 2))).intValue();

    int end1 = start + js[0];

    int start2 = end1 + break1length + Double.valueOf(IDENT).intValue();
    int end2 = start2 + js[1];

    int start3 = end2 + break2length + Double.valueOf(IDENT).intValue();
    int end3 = start3 + js[2];

    for (int i = 0; i < seriesSpan; i++) {
      res[i] = randoms.nextGaussian(0, STDEV);
      if (i > start && i <= end1) {
        res[i] = randoms.nextGaussian(1, STDEV);
      }
      if (i > start2 && i <= end2) {
        res[i] = randoms.nextGaussian(1, STDEV);
      }
      if (i > start3 && i <= end3) {
        res[i] = randoms.nextGaussian(1, STDEV);
      }

    }
    return res;
  }

  public static double[] threePeriodsOfAmplitude(int seriesSpan, int[] js, int[] as) {

    double[] res = new double[seriesSpan];

    // int break1start = Double.valueOf(randoms.nextUniform(0d, (double) activitySpan)).intValue();
    int total = 0;
    for (int i : js) {
      total = total + i;
    }

    int break1length = Double.valueOf(
        randoms.nextUniform(0, (double) seriesSpan - (total + IDENT * 2 + IDENT * 2))).intValue();
    // IDENT*2 - right and left idents
    // IDENT*2 - idents between peaks

    int break2length = Double.valueOf(
        randoms.nextUniform(0, (double) seriesSpan - (total + break1length + IDENT * 2 + IDENT)))
        .intValue();

    int start = Double.valueOf(
        randoms.nextUniform(IDENT, (double) seriesSpan
            - (total + break1length + break2length + IDENT * 2 + IDENT * 2))).intValue();

    int end1 = start + js[0];

    int start2 = end1 + break1length + Double.valueOf(IDENT).intValue();
    int end2 = start2 + js[1];

    int start3 = end2 + break2length + Double.valueOf(IDENT).intValue();
    int end3 = start3 + js[2];

    for (int i = 0; i < seriesSpan; i++) {
      res[i] = randoms.nextGaussian(0, STDEV);
      if (i > start && i <= end1) {
        res[i] = randoms.nextGaussian(as[0], STDEV);
      }
      if (i > start2 && i <= end2) {
        res[i] = randoms.nextGaussian(as[1], STDEV);
      }
      if (i > start3 && i <= end3) {
        res[i] = randoms.nextGaussian(as[2], STDEV);
      }

    }
    return res;
  }
}
