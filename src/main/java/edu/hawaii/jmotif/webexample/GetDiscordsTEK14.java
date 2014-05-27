package edu.hawaii.jmotif.webexample;

import java.util.Date;
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
public class GetDiscordsTEK14 {

  private static final int windowSize = 128;
  private static final int alphabetSize = 5;
  private static final String attribute = "value0";

  /**
   * Executable method.
   * 
   * @param args None used.
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    // get the data first
    Instances tsData = readTSData();

    Date start = new Date();
    // now build the SAX data structure using sliding window of size 40 and alphabet of 3
    DiscordRecords dr = SAXFactory.instances2Discords(tsData, attribute, windowSize, alphabetSize, 10);

    Date end = new Date();

    // printout the discords occurrences
    System.out.println(dr.toString());

    System.out.println(" Elapsed time: " + timeToString(start.getTime(), end.getTime()));

  }

  /**
   * Read the timeseries data into WEKA format.
   * 
   * @return Timeseries.
   * @throws Exception If error occurs.
   */
  private static Instances readTSData() throws Exception {
    Instances data = DataSource.read("data//ts_data//TEK16.arff");
    return data;
  }

  private static String timeToString(long start, long finish) {
    long diff = finish - start;

    long secondInMillis = 1000;
    long minuteInMillis = secondInMillis * 60;
    long hourInMillis = minuteInMillis * 60;
    long dayInMillis = hourInMillis * 24;
    long yearInMillis = dayInMillis * 365;

    @SuppressWarnings("unused")
    long elapsedYears = diff / yearInMillis;
    diff = diff % yearInMillis;

    @SuppressWarnings("unused")
    long elapsedDays = diff / dayInMillis;
    diff = diff % dayInMillis;

    @SuppressWarnings("unused")
    long elapsedHours = diff / hourInMillis;
    diff = diff % hourInMillis;

    long elapsedMinutes = diff / minuteInMillis;
    diff = diff % minuteInMillis;

    long elapsedSeconds = diff / secondInMillis;
    diff = diff % secondInMillis;

    long elapsedMilliseconds = diff % secondInMillis;

    return elapsedMinutes + "m " + elapsedSeconds + "s " + elapsedMilliseconds + "ms";
  }

}
