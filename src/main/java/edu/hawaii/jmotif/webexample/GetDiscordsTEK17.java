package edu.hawaii.jmotif.webexample;

import weka.core.Instances;
import weka.core.converters.ConverterUtils.DataSource;
import edu.hawaii.jmotif.sax.SAXFactory;
import edu.hawaii.jmotif.sax.datastructures.DiscordRecords;

/**
 * The discords experiment code. see the example on the web and more detailed description in the
 * Keogh's article.
 * 
 * @author Pavel Senin.
 * 
 */
public class GetDiscordsTEK17 {

  private static final int SLIDING_WINDOW_SIZE = 40;
  private static final int ALPHABET_SIZE = 5;
  private static final String DATA_VALUE_ATTRIBUTE = "value0";

  /**
   * Executable method.
   * 
   * @param args None used.
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    // get the data first
    Instances tsData = readTSData();

    // find discords
    DiscordRecords dr = SAXFactory.instances2Discords(tsData, DATA_VALUE_ATTRIBUTE,
        SLIDING_WINDOW_SIZE, ALPHABET_SIZE, 5);

    // printout the discords occurrences
    System.out.println("\nFive best discords:\n\n" + dr.toString());

    System.out.println("\n\n\ndiscords=t(rev(c(" + dr.toCoordinates() + ")))\nwords=t(rev(c("
        + dr.toPayloads() + ")))\ndistances=t(rev(c(" + dr.toDistances() + ")))\n\nDONE");

  }

  /**
   * Read the timeseries data into WEKA format.
   * 
   * @return Timeseries.
   * @throws Exception If error occurs.
   */
  private static Instances readTSData() throws Exception {
    Instances data = DataSource.read("data//ts_data//TEK17.arff");
    return data;
  }
}
