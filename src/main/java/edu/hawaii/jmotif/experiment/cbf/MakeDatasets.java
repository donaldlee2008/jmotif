package edu.hawaii.jmotif.experiment.cbf;

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
      save("cbf_" + num + ".csv", set);
    }

  }

  private static Map<String, ArrayList<double[]>> makeSet(int num) {

    // ticks - i.e. time
    int[] t = new int[128];
    for (int i = 0; i < 128; i++) {
      t[i] = i;
    }

    Map<String, ArrayList<double[]>> set = new HashMap<String, ArrayList<double[]>>();

    ArrayList<double[]> c = new ArrayList<double[]>();
    for (int i = 0; i < num; i++) {
      c.add(CBFGenerator.cylinder(t));
    }

    ArrayList<double[]> b = new ArrayList<double[]>();
    for (int i = 0; i < num; i++) {
      b.add(CBFGenerator.bell(t));
    }

    ArrayList<double[]> f = new ArrayList<double[]>();
    for (int i = 0; i < num; i++) {
      f.add(CBFGenerator.funnel(t));
    }

    set.put("1", c);
    set.put("2", b);
    set.put("3", f);

    return set;
  }

  private static void save(String fname, Map<String, ArrayList<double[]>> set) throws IOException {
    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(fname)));
    for (Entry<String, ArrayList<double[]>> e : set.entrySet()) {
      for (double[] a : e.getValue()) {
        bw.write(e.getKey()
            + " "
            + Arrays.toString(a).replace("[", "").replace("]", "").replaceAll(" ", "")
                .replace(",", " ") + "\n");
      }
    }
    bw.close();
  }

}
