package edu.hawaii.jmotif.experiment.physionet;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import edu.hawaii.jmotif.timeseries.TSUtils;

public class MakeTrainTestSets {

  private static final String COMMA = ",";
  private static final String CR = "\n";

  static Map<String, ArrayList<double[]>> res = new HashMap<String, ArrayList<double[]>>();

  private static final String PREFIX = "/media/DB/workspace-school/jmotif/physio/";
  private static final String[] files = { "mgh076samples.csv" };

//  private static final String[] files = { "3000531samples.csv", "3400045samples.csv",
//      "3400171samples.csv", "3400425samples.csv", "3400771samples.csv" };

//  private static final String[] keys = { "II", "AVR", "V", "RESP", "PLETH" };
  private static final String[] keys = { "CO2" };

  private static final int SERIES_SIZE = 2048;
  private static final int MAX_SAMPLES_FROM_SET = 500;

  /**
   * @param args
   * @throws IOException
   */
  public static void main(String[] args) throws IOException {

    for (String key : keys) {
      res.put(key, new ArrayList<double[]>());
    }

    for (String file : files) {
      getSeries(res, SERIES_SIZE, file);
    }

    for (int i = 0; i < 5; i++) {
      res.put(String.valueOf(i), new ArrayList<double[]>());
    }

    BufferedWriter bw = new BufferedWriter(new FileWriter(new File("physio/PHYSIO_CLUSTER.csv")));
    for (Entry<String, ArrayList<double[]>> e : res.entrySet()) {
      // sampleCounter = 0;
      for (double[] arr : e.getValue()) {
        bw.write(String.valueOf(e.getKey()) + COMMA
            + Arrays.toString(arr).replace("[", "").replace("]", "").replace(" ", "") + CR);
      }
    }

    bw.close();

  }

  private static void getSeries(Map<String, ArrayList<double[]>> res, int seriesSize,
      String fileName) throws NumberFormatException, IOException {

    // setup the reader
    //
    BufferedReader br = new BufferedReader(new FileReader(new File(PREFIX + fileName)));
    String line = null;
    int lineCounter = 0;
    int sampleCounter = 0;

    // parse the header
    //
    String header = br.readLine();
    String[] colNames = header.split(",");
    Map<String, Integer> columns = new HashMap<String, Integer>();
    for (String key : keys) {
      for (int i = 0; i < colNames.length; i++) {
        if (colNames[i].contains(key)) {
          columns.put(key, i);
        }
      }
    }

    // make a local res map
    //
    Map<String, ArrayList<Double>> cDat = new HashMap<String, ArrayList<Double>>();
    for (String key : keys) {
      cDat.put(key, new ArrayList<Double>());
    }

    line = br.readLine();
    // go
    //
    while ((line = br.readLine()) != null) {

      lineCounter++;

      String[] split = line.split(",");

      Double signal0 = parseValue(split[columns.get(keys[0])]);
//      Double signal1 = parseValue(split[columns.get(keys[1])]);
//      Double signal2 = parseValue(split[columns.get(keys[2])]);
//      Double signal3 = parseValue(split[columns.get(keys[3])]);
//      Double signal4 = parseValue(split[columns.get(keys[4])]);

      cDat.get(keys[0]).add(signal0);
//      cDat.get(keys[1]).add(signal1);
//      cDat.get(keys[2]).add(signal2);
//      cDat.get(keys[3]).add(signal3);
//      cDat.get(keys[4]).add(signal4);

      if (lineCounter > 1 && (lineCounter - 1) % SERIES_SIZE == 0) {
        sampleCounter++;

        // check the intermediate result for sanity
        //
        for (String key : keys) {

          double[] arr = toDoubleArray(cDat.get(String.valueOf(key)));

          // check if signal is here
          //
          double mean = TSUtils.mean(arr);
          double stDev = TSUtils.stDev(arr);

          if (!Double.isNaN(mean) && stDev > 0.01 && TSUtils.countNaN(arr) == 0) {
            res.get(key).add(arr);
          }

        }

        // reset the local store
        //
        cDat = new HashMap<String, ArrayList<Double>>();
        for (String key : keys) {
          cDat.put(key, new ArrayList<Double>());
        }

        if (sampleCounter > MAX_SAMPLES_FROM_SET) {
          break;
        }
      }

    }
    br.close();

  }

  private static Double parseValue(String string) {
    Double res = Double.NaN;
    try {
      Double r = Double.valueOf(string);
      res = r;
    }
    catch (NumberFormatException e) {
      System.err.println("err parsing " + string + " to Double");
    }
    return res;
  }

  private static double[] toDoubleArray(ArrayList<Double> arrayList) {
    double[] res = new double[arrayList.size()];
    for (int i = 0; i < arrayList.size(); i++) {
      res[i] = arrayList.get(i);
    }
    return res;
  }
}