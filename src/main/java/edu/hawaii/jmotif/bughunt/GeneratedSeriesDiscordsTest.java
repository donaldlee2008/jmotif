package edu.hawaii.jmotif.bughunt;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import edu.hawaii.jmotif.sax.LargeWindowAlgorithm;
import edu.hawaii.jmotif.sax.SAXFactory;
import edu.hawaii.jmotif.sax.datastructures.DiscordRecords;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;
import edu.hawaii.jmotif.timeseries.Timeseries;

/**
 * The discords experiment code. see the example on the web and more detailed description in the
 * Keogh's article.
 * 
 * @author Pavel Senin.
 * 
 */
public class GeneratedSeriesDiscordsTest {

  private static final int DATA_SIZE = 5000;

  private static final int SLIDING_WINDOW_SIZE = 128;

  private static final int NUMBER_DISCORDS_TO_GET = 10;

  private static final int ALPHABET_SIZE = 4;

  /**
   * Executable method.
   * 
   * @param args None used.
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    // get the data first
    Timeseries data = generateTimeseries();

    // get the real-valued series
    double[] vals = data.values();

    // save data
    saveRealSeries("sandbox/generated_series_raw.csv", vals, 0D, 1D);

    double[] PAA = TSUtils.paa(
        vals,
        Double.valueOf(
            (Double.valueOf(DATA_SIZE) / Double.valueOf(SLIDING_WINDOW_SIZE))
                * Double.valueOf(ALPHABET_SIZE)).intValue());

    saveRealSeries("sandbox/generated_series_paa.csv", PAA, Double.valueOf(SLIDING_WINDOW_SIZE)
        / Double.valueOf(ALPHABET_SIZE * 2),
        Double.valueOf(SLIDING_WINDOW_SIZE) / Double.valueOf(ALPHABET_SIZE));

    DiscordRecords dr = SAXFactory.series2Discords(vals, SLIDING_WINDOW_SIZE, ALPHABET_SIZE,
        NUMBER_DISCORDS_TO_GET, new LargeWindowAlgorithm());

    System.out.println("\n\n\n" + dr.toString() + "\n\n\ndiscords=t(rev(c(" + dr.toCoordinates()
        + ")))\nwords=t(rev(c(" + dr.toPayloads() + ")))\ndistances=t(rev(c(" + dr.toDistances()
        + ")))\n\nDONE");

  }

  private static void saveRealSeries(String filename, double[] data, double start, double step)
      throws IOException {
    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(filename)));
    for (int i = 0; i < data.length; i++) {
      bw.write(String.valueOf(start + i * step) + "," + Double.valueOf(data[i]) + "\n");
    }
    bw.close();
  }

  public static Timeseries generateTimeseries() throws TSException {

    double[] val = new double[DATA_SIZE];
    long[] time = new long[DATA_SIZE];

    double period = 800.;
    double ampl = 5.;
    for (int i = 0; i < DATA_SIZE; i++) {
      time[i] = i;
      double noise = 0.; // 2 * Math.random() - 1.;
      val[i] = ampl * Math.sin(2. * Math.PI * i / period) + noise;
      if (time[i] > 1300 && time[i] < 1500 && val[i] < 0) {
        val[i] = 0.;
      }
      else if (time[i] > 2500 && time[i] < 2600 && val[i] > ampl / 2.) {
        val[i] = ampl / 5.;
      }
      else if (time[i] > 3400 && time[i] < 3500 && val[i] > ampl / 2.) {
        val[i] = -ampl / 5.;
      }
      val[i] += noise;
    }
    Timeseries ts = new Timeseries(val, time);
    return ts;
  }

}
