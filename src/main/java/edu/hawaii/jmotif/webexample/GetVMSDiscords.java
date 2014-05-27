package edu.hawaii.jmotif.webexample;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import edu.hawaii.jmotif.sax.LargeWindowAlgorithm;
import edu.hawaii.jmotif.sax.SAXFactory;
import edu.hawaii.jmotif.sax.datastructures.DiscordRecords;

/**
 * The discords experiment code. see the example on the web and more detailed description in the
 * Keogh's article.
 * 
 * @author Pavel Senin.
 * 
 */
public class GetVMSDiscords {

  private static final int SLIDING_WINDOW_SIZE = 20;
  private static final int ALPHABET_SIZE = 5;
  private static final String FILENAME = "/media/DB/vms/vms_distance_PY-91090.txt";

  /**
   * Executable method.
   * 
   * @param args None used.
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    // get the data first
    double[] series = readTSData(FILENAME, 1);

    // find discords
    DiscordRecords dr = SAXFactory.series2Discords(series, SLIDING_WINDOW_SIZE, ALPHABET_SIZE, 8,
        new LargeWindowAlgorithm());

    // printout the discords occurrences
    System.out.println("\nFive best discords:\n\n" + dr.toString());

    System.out.println("\n\n\ndiscords=t(rev(c(" + dr.toCoordinates() + ")))\nwords=t(rev(c("
        + dr.toPayloads() + ")))\ndistances=t(rev(c(" + dr.toDistances() + ")))\n\nDONE");

  }

  private static double[] readTSData(String fname, int skipLines) throws Exception {

    ArrayList<Double> preSeries = new ArrayList<Double>();

    BufferedReader br = new BufferedReader(new FileReader(new File(fname)));

    int lineCounter = 0;
    String line = null;
    while ((line = br.readLine()) != null) {

      lineCounter++;
      if (skipLines >= lineCounter) {
        continue;
      }

      String[] split = line.split("\t");

      Double value = Double.valueOf(split[2].trim());

      preSeries.add(value);

    }

    br.close();

    double[] res = new double[preSeries.size()];
    for (int i = 0; i < preSeries.size(); i++) {
      res[i] = preSeries.get(i);
    }

    return res;
  }
}
