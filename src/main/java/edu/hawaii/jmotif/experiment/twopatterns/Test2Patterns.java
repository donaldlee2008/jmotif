package edu.hawaii.jmotif.experiment.twopatterns;

import java.util.Arrays;

public class Test2Patterns {

  public static void main(String[] args) {

    double[] uu = TwoPatternsGenerator.uu(new int[128]);
    System.out.println("uu = c(" + Arrays.toString(uu).replace("[", "").replace("]", "") + ")");

    double[] dd = TwoPatternsGenerator.dd(new int[128]);
    System.out.println("dd = c(" + Arrays.toString(dd).replace("[", "").replace("]", "") + ")");

    double[] ud = TwoPatternsGenerator.ud(new int[128]);
    System.out.println("ud = c(" + Arrays.toString(ud).replace("[", "").replace("]", "") + ")");

    double[] du = TwoPatternsGenerator.du(new int[128]);
    System.out.println("du = c(" + Arrays.toString(du).replace("[", "").replace("]", "") + ")");

  }

}
