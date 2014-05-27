package edu.hawaii.jmotif.experiment.twopatterns;

import cc.mallet.util.Randoms;

/**
 * CBF Domain data generator.
 * 
 * @author psenin
 * 
 */
public class TwoPatternsGenerator {

  private static Randoms randoms;

  private static final double UP = 5.0d;

  private static final double DOWN = -5.0d;

  static {
    randoms = new Randoms();
  }

  public static synchronized int getStepWidth() {
    return (int) Math.round(randoms.nextUniform(20d, 30d));
  }

  public static synchronized double[] dd(int[] t) {

    int len = t.length - 1;
    double[] res = new double[t.length];

    int u1Width = getStepWidth();

    int u2Width = getStepWidth();

    int u1Start = (int) Math.floor(randoms.nextUniform(0d, (double) len - u1Width - u2Width));

    int u2Start = (int) Math.floor(randoms.nextUniform(u1Start + u1Width, (double) len - u2Width));

    // System.out.println(u1Start + ", " + u1Width + "; " + u2Start + ", " + u2Width);

    for (int i = 0; i < u1Start; i++) {
      res[i] = randoms.nextGaussian();
    }

    for (int i = u1Start; i < u1Start + u1Width / 2; i++) {
      res[i] = UP;
    }
    for (int i = u1Start + u1Width / 2; i < u1Start + u1Width; i++) {
      res[i] = DOWN;
    }

    for (int i = u1Start + u1Width; i < u2Start; i++) {
      res[i] = randoms.nextGaussian();
    }

    for (int i = u2Start; i < u2Start + u2Width / 2; i++) {
      res[i] = UP;
    }
    for (int i = u2Start + u2Width / 2; i < u2Start + u2Width; i++) {
      res[i] = DOWN;
    }

    for (int i = u2Start + u2Width; i < len; i++) {
      res[i] = randoms.nextGaussian();
    }

    return res;
  }

  public static synchronized double[] ud(int[] t) {

    int len = t.length - 1;
    double[] res = new double[t.length];

    int u1Width = getStepWidth();

    int u2Width = getStepWidth();

    int u1Start = (int) Math.floor(randoms.nextUniform(0d, (double) len - u1Width - u2Width));

    int u2Start = (int) Math.floor(randoms.nextUniform(u1Start + u1Width, (double) len - u2Width));

    // System.out.println(u1Start + ", " + u1Width + "; " + u2Start + ", " + u2Width);

    for (int i = 0; i < u1Start; i++) {
      res[i] = randoms.nextGaussian();
    }

    for (int i = u1Start; i < u1Start + u1Width / 2; i++) {
      res[i] = DOWN;
    }
    for (int i = u1Start + u1Width / 2; i < u1Start + u1Width; i++) {
      res[i] = UP;
    }

    for (int i = u1Start + u1Width; i < u2Start; i++) {
      res[i] = randoms.nextGaussian();
    }

    for (int i = u2Start; i < u2Start + u2Width / 2; i++) {
      res[i] = UP;
    }
    for (int i = u2Start + u2Width / 2; i < u2Start + u2Width; i++) {
      res[i] = DOWN;
    }

    for (int i = u2Start + u2Width; i < len; i++) {
      res[i] = randoms.nextGaussian();
    }

    return res;
  }

  public static synchronized double[] uu(int[] t) {

    int len = t.length - 1;
    double[] res = new double[t.length];

    int u1Width = getStepWidth();

    int u2Width = getStepWidth();

    int u1Start = (int) Math.floor(randoms.nextUniform(0d, (double) len - u1Width - u2Width));

    int u2Start = (int) Math.floor(randoms.nextUniform(u1Start + u1Width, (double) len - u2Width));

    // System.out.println(u1Start + ", " + u1Width + "; " + u2Start + ", " + u2Width);

    for (int i = 0; i < u1Start; i++) {
      res[i] = randoms.nextGaussian();
    }

    for (int i = u1Start; i < u1Start + u1Width / 2; i++) {
      res[i] = DOWN;
    }
    for (int i = u1Start + u1Width / 2; i < u1Start + u1Width; i++) {
      res[i] = UP;
    }

    for (int i = u1Start + u1Width; i < u2Start; i++) {
      res[i] = randoms.nextGaussian();
    }

    for (int i = u2Start; i < u2Start + u2Width / 2; i++) {
      res[i] = DOWN;
    }
    for (int i = u2Start + u2Width / 2; i < u2Start + u2Width; i++) {
      res[i] = UP;
    }

    for (int i = u2Start + u2Width; i < len; i++) {
      res[i] = randoms.nextGaussian();
    }

    return res;
  }

  public static synchronized double[] du(int[] t) {

    int len = t.length - 1;
    double[] res = new double[t.length];

    int u1Width = getStepWidth();

    int u2Width = getStepWidth();

    int u1Start = (int) Math.floor(randoms.nextUniform(0d, (double) len - u1Width - u2Width));

    int u2Start = (int) Math.floor(randoms.nextUniform(u1Start + u1Width, (double) len - u2Width));

    // System.out.println(u1Start + ", " + u1Width + "; " + u2Start + ", " + u2Width);

    for (int i = 0; i < u1Start; i++) {
      res[i] = randoms.nextGaussian();
    }

    for (int i = u1Start; i < u1Start + u1Width / 2; i++) {
      res[i] = UP;
    }
    for (int i = u1Start + u1Width / 2; i < u1Start + u1Width; i++) {
      res[i] = DOWN;
    }

    for (int i = u1Start + u1Width; i < u2Start; i++) {
      res[i] = randoms.nextGaussian();
    }

    for (int i = u2Start; i < u2Start + u2Width / 2; i++) {
      res[i] = DOWN;
    }
    for (int i = u2Start + u2Width / 2; i < u2Start + u2Width; i++) {
      res[i] = UP;
    }

    for (int i = u2Start + u2Width; i < len; i++) {
      res[i] = randoms.nextGaussian();
    }

    return res;
  }
}
