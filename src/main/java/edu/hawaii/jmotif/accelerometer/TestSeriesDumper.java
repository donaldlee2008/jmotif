package edu.hawaii.jmotif.accelerometer;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

public class TestSeriesDumper {

  /**
   * @param args
   * @throws IOException
   */
  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new FileReader(new File(
        "/media/DB/accelerometer/test.csv")));

    br.readLine();

    String line = "";

    String oldSequence = "";
    ArrayList<APoint> series = new ArrayList<APoint>();

    while ((line = br.readLine()) != null) {

      String[] split = line.split(",");

      String sequenceId = split[4];

      if (oldSequence.length() == 0) {
        oldSequence = sequenceId;
      }

      if (sequenceId.equalsIgnoreCase(oldSequence)) {
        series.add(new APoint(line));
      }
      else {
        save(oldSequence, series);

        oldSequence = sequenceId;

        series = new ArrayList<APoint>();
        series.add(new APoint(line));

      }

    }

  }

  private static void save(String deviceId, ArrayList<APoint> arrayList) throws IOException {

    long start = arrayList.get(0).getTs();
    long end = arrayList.get(arrayList.size() - 1).getTs();

    String fName = "/media/DB/accelerometer/test_series/" + String.valueOf(deviceId) + "_" + start
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
