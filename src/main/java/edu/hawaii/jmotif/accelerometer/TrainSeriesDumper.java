package edu.hawaii.jmotif.accelerometer;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.concurrent.atomic.AtomicInteger;

public class TrainSeriesDumper {

  /**
   * @param args
   * @throws IOException
   */
  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new FileReader(new File(
        "/media/DB/accelerometer/train.csv")));

    HashMap<String, BufferedWriter> outputs = new HashMap<String, BufferedWriter>();
    HashMap<String, AtomicInteger> seriesCounter = new HashMap<String, AtomicInteger>();
    HashMap<String, Long> timestamps = new HashMap<String, Long>();
    HashMap<String, ArrayList<APoint>> series = new HashMap<String, ArrayList<APoint>>();

    String line = "";
    // int counter = 0;
    String header = br.readLine();

    long oldTS = 0;

    while ((line = br.readLine()) != null) {

      String[] split = line.split(",");

      Long cTS = Double.valueOf(split[0]).longValue();
      String deviceId = split[4];

      if (!(outputs.containsKey(deviceId))) {

        BufferedWriter bw = new BufferedWriter(new FileWriter("/media/DB/accelerometer/train_"
            + deviceId + ".csv"));
        bw.write(header + ",seriesId\n");
        outputs.put(deviceId, bw);

        seriesCounter.put(deviceId, new AtomicInteger(0));

        timestamps.put(deviceId, cTS);

        series.put(deviceId, new ArrayList<APoint>());

      }

      if (Math.abs(cTS.longValue() - timestamps.get(deviceId).longValue()) > 11 * 1000) {
        seriesCounter.get(deviceId).incrementAndGet();
        save(deviceId, series.get(deviceId));
        series.put(deviceId, new ArrayList<APoint>());
      }
      else {
        series.get(deviceId).add(new APoint(line));
      }

      outputs.get(deviceId).write(line + "," + seriesCounter.get(deviceId) + "\n");

      // String tstamp = line.split(",")[0];
      // DateTime dt = new DateTime(Long.valueOf(tstamp));
      // System.out.println(dt);

      timestamps.put(deviceId, cTS);

    }

    for (BufferedWriter bw : outputs.values()) {
      bw.close();
    }

  }

  private static void save(String deviceId, ArrayList<APoint> arrayList) throws IOException {

    long start = arrayList.get(0).getTs();
    long end = arrayList.get(arrayList.size() - 1).getTs();

    String fName = "/media/DB/accelerometer/train_series/" + String.valueOf(deviceId) + "_" + start
        + "_" + end + ".csv";
    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(fName)));

    int counter = 0;
    for (APoint p : arrayList) {
      String line = p.toFileLine();
      if (counter > 0) {
        line = line + "," + distance(p, arrayList.get(counter - 1));
      }
      else {
        line = line + ",0.0";
      }
      bw.write(line + "\n");
      counter++;
    }
    bw.close();
  }

  private static double distance(APoint p, APoint aPoint) {
    return p.distanceTo(aPoint);
  }
}
