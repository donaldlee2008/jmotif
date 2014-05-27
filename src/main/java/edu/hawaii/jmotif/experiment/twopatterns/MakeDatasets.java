package edu.hawaii.jmotif.experiment.twopatterns;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

public class MakeDatasets {

  private static final int[] sets = { 50, 100, 200, 400, 800, 1600, 3200, 6400, 10000 };

  public static void main(String[] args) throws IOException {

    for (int num : sets) {
      Map<String, ArrayList<double[]>> set = makeSet(num);
      save("two_patterns_" + num + ".csv", set);
    }

  }

  private static Map<String, ArrayList<double[]>> makeSet(int num) {
    Map<String, ArrayList<double[]>> set = new HashMap<String, ArrayList<double[]>>();

    ArrayList<double[]> uu = new ArrayList<double[]>();
    for (int i = 0; i < num; i++) {
      uu.add(TwoPatternsGenerator.uu(new int[128]));
    }

    ArrayList<double[]> ud = new ArrayList<double[]>();
    for (int i = 0; i < num; i++) {
      ud.add(TwoPatternsGenerator.ud(new int[128]));
    }

    ArrayList<double[]> du = new ArrayList<double[]>();
    for (int i = 0; i < num; i++) {
      du.add(TwoPatternsGenerator.du(new int[128]));
    }

    ArrayList<double[]> dd = new ArrayList<double[]>();
    for (int i = 0; i < num; i++) {
      dd.add(TwoPatternsGenerator.dd(new int[128]));
    }

    set.put("1", dd);
    set.put("2", ud);
    set.put("3", du);
    set.put("4", uu);

    return set;
  }

  private static void save(String fname, Map<String, ArrayList<double[]>> set) throws IOException {
    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(fname)));
    for (Entry<String, ArrayList<double[]>> e : set.entrySet()) {
      for (double[] a : e.getValue()) {
        bw.write(e.getKey() + ","
            + Arrays.toString(a).replace("[", "").replace("]", "").replaceAll(" ", "") + "\n");
      }
    }
    bw.close();
  }

}
