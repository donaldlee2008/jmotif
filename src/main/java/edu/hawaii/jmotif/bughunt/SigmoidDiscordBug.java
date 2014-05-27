package edu.hawaii.jmotif.bughunt;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Arrays;
import edu.hawaii.jmotif.sax.SAXFactory;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.sax.trie.TrieException;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;
import edu.hawaii.jmotif.timeseries.Timeseries;

public class SigmoidDiscordBug {

  private static int GENERATED_SERIES_LENGTH = 5000;

  private static final int SLIDING_WINDOW_SIZE = 128;

  private static final int NUMBER_DISCORDS_TO_GET = 10;

  private static final int ALPHABET_SIZE = 4;

  private static final String COMMA = ",";

  private static final Object SEPARATOR = " | ";

  private static final Object CR = "\n";

  /**
   * @param args
   * @throws TSException
   * @throws TrieException
   */
  public static void main(String[] args) throws TSException, TrieException {

    Timeseries series = generateTimeseries(3);

    // for (TPoint tp : series) {
    // System.out.println(tp.value());
    // }

    NormalAlphabet normalA = new NormalAlphabet();
    double[] cuts = normalA.getCuts(ALPHABET_SIZE);

    // build the trie
    //
    int currPosition = 0;
    while ((currPosition + SLIDING_WINDOW_SIZE) < GENERATED_SERIES_LENGTH) {

      // get the window SAX representation
      double[] subSeries = SAXFactory.getSubSeries(series.values(), currPosition, currPosition
          + SLIDING_WINDOW_SIZE);

      // ******************** DEBUG ********************
      //
      //
      // saxVals = TSUtils.ts2String(TSUtils.zNormalize(TSUtils.paa(vals, cuts.length + 1)), cuts);
      //
      //
      //

      StringBuffer sb = new StringBuffer();
      sb.append(currPosition).append(SEPARATOR);
      sb.append("data: ").append(arrayToString(subSeries)).append(SEPARATOR);

      double[] paaVals = TSUtils.paa(subSeries, cuts.length + 1);
      sb.append("paa: ").append(arrayToString(paaVals)).append(SEPARATOR);

      double[] zNormalValues = TSUtils.zNormalize(paaVals);
      sb.append("Znormal: ").append(arrayToString(zNormalValues)).append(SEPARATOR);

      char[] saxVals = SAXFactory.getSaxVals(subSeries, SLIDING_WINDOW_SIZE,
          normalA.getCuts(ALPHABET_SIZE));
      sb.append("sax: ").append(Arrays.toString(saxVals)).append(CR);

      if ((currPosition > 500 && currPosition < 700)
          || (currPosition > 2573 && currPosition < 2580)) {
        System.out.print(sb.toString());
      }

      currPosition++;

    }

    // DiscordRecords dr = SAXFactory.series2Discords(series.values(), SLIDING_WINDOW_SIZE,
    // ALPHABET_SIZE, NUMBER_DISCORDS_TO_GET, new LargeWindowAlgorithm());

  }

  private static String arrayToString(double[] data) {
    NumberFormat nf = new DecimalFormat("0.00");
    StringBuffer sb = new StringBuffer();
    for (double d : data) {
      sb.append(nf.format(d)).append(COMMA);
    }
    return sb.delete(sb.length() - 1, sb.length()).toString();
  }

  public static Timeseries generateTimeseries(int id) throws TSException {

    double[] val = new double[GENERATED_SERIES_LENGTH];
    long[] time = new long[GENERATED_SERIES_LENGTH];

    double period;
    double ampl;

    switch (id) {
    case 0:
      // First dimension
      period = 800.;
      ampl = 15; // 25.;
      for (int i = 0; i < GENERATED_SERIES_LENGTH; i++) {
        time[i] = i;
        double noise = 2. * Math.random() - 1.;
        val[i] = ampl * Math.sin(2. * Math.PI * i / period);

        if (time[i] > 1300 && time[i] < 1500 && val[i] < 0) {
          val[i] = 0.;
        }
        else if (time[i] > 2500 && time[i] < 2600 && val[i] > ampl / 2.) {
          val[i] = -ampl / 4.;
          // val[i] = ampl / 5.;

        }
        else if (time[i] > 3400 && time[i] < 3500 && val[i] > ampl / 2.) {
          val[i] = ampl / 5.;
          // val[i] = -ampl / 5.;

        }
        val[i] += noise;
      }
      break;
    case 1:
      // Second dimension
      period = 500.;
      ampl = 15.;
      for (int i = 0; i < GENERATED_SERIES_LENGTH; i++) {
        time[i] = i;
        // double noise = 2 * Math.random() - 1.;
        val[i] = ampl * Math.sin(2. * Math.PI * i / period);

        if (val[i] < -ampl * 0.8) {
          val[i] = -(val[i] + ampl * 0.8);
        }
        if (val[i] < -ampl * 0.2) {
          val[i] = -ampl * 0.2;
        }
        if (time[i] > 2800 && time[i] < 2950) {
          val[i] = -ampl * 0.2;
        }
        if (time[i] > 500 && time[i] < 700 && val[i] > ampl / 1.7) {
          val[i] = ampl / 1.7;
        }
        if (time[i] > 3800 && time[i] < 4000 && val[i] > 0) {
          val[i] = val[i] * 2.5;
        }
        // val[i] += noise;
      }
      break;
    case 2:
      // Third dimension
      period = 350.;
      ampl = 10.;
      for (int i = 0; i < GENERATED_SERIES_LENGTH; i++) {
        time[i] = i;
        // double noise = 2 * Math.random() - 1.;
        val[i] = ampl * Math.sin(2. * Math.PI * i / period);
        if (val[i] > ampl * 0.8) {
          val[i] = ampl * 0.8;
        }
        else if (val[i] < -1 * ampl / 4.) {
          val[i] = -1 * ampl / 4.;
        }

        if (time[i] > 3100 && time[i] < 3200) {
          val[i] = 0;

        }
        if (time[i] > 2570 && time[i] < 2630) {
          val[i] = 0;
        }
        if (time[i] > 2300 && time[i] < 2350) {
          val[i] = ampl * .08;
        }
        if (time[i] > 4500 && time[i] < 4570) {
          val[i] = -1 * ampl / 2.;
        }
        if (time[i] > 420 && time[i] < 450) {
          val[i] = ampl * 0.5;
        }
        // val[i] += noise;
      }
      break;
    case 3:
      // Fourth dimension
      period = 1000.;
      ampl = 20.;
      double arg = 0.;
      double strechFactor = 50.;
      double boundary = 8.;
      for (int i = 0; i < GENERATED_SERIES_LENGTH; i++) {
        time[i] = i;
        // double noise = 2 * Math.random() - 1.;
        arg = (i - (Math.floor(i / period)) * period) / strechFactor - boundary;
        val[i] = ampl / (1 + Math.exp(-(arg)));

        if (arg < -boundary || arg > boundary) {
          val[i] = 0.;
        }
        else {
          // val[i] = ampl / (1 + Math.exp(-(arg)));
        }
        if (time[i] > 2700 && time[i] < 3000) {
          val[i] = 0;
        }
        else if (time[i] > 4200 && time[i] < 4400 && val[i] < ampl / 3.) {
          val[i] = ampl / 3.;
        }
        // val[i] += noise;
      }
      break;
    default:
      period = 800.;
      ampl = 5.;
      for (int i = 0; i < GENERATED_SERIES_LENGTH; i++) {
        time[i] = i;
        double noise = 2 * Math.random() - 1.;
        val[i] = ampl * Math.sin(2. * Math.PI * i / period) + noise;
        if (time[i] > 3400 && time[i] < 3500 && val[i] > ampl / 2.) {

        }
        else if (time[i] > 2500 && time[i] < 2600 && val[i] > ampl / 2.) {
          // val[i] = ampl/5. + noise;
        }
        val[i] += noise;
      }
      break;
    }
    return new Timeseries(val, time);
  }

  @SuppressWarnings("unused")
  private static void saveRealSeries(String filename, double[] data, double start, double step)
      throws IOException {
    BufferedWriter bw = new BufferedWriter(new FileWriter(new File(filename)));
    for (int i = 0; i < data.length; i++) {
      bw.write(String.valueOf(start + i * step) + "," + Double.valueOf(data[i]) + "\n");
    }
    bw.close();
  }
}
