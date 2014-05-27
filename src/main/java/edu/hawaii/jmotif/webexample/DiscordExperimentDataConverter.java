package edu.hawaii.jmotif.webexample;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import javax.xml.datatype.XMLGregorianCalendar;
import org.hackystat.utilities.tstamp.Tstamp;

/**
 * The helper to move data from the ECG format into the WEKA ARFF data format.
 *
 * @author Pavel Senin.
 *
 */
public class DiscordExperimentDataConverter {

  // in and out data location
  private static final String dataFolfer = "data//ts_data";
  private static final String inputFName = "qtdbsele0606.txt";
  private static final String outputFName = "qtdbsele0606.arff";
  private static final String TIME_ZERO = "2010-01-01T10:00:00.000";
  private static final String COMMA = ",";
  private static final String CR = "\n";

  /**
   * Main runnable method.
   *
   * @param args None accepted.
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    // get the input and output ready
    BufferedReader in = new BufferedReader(new
        FileReader(new File(dataFolfer + "//" + inputFName)));

    BufferedWriter out = new BufferedWriter(new FileWriter(
        new File(dataFolfer + "//" + outputFName)));

    out.write(getHeader());

    String line;

    // do the conversion cycle
    while ((line = in.readLine()) != null) {

      // do the date conversion here
      //
      String[] splitLine = line.split("\\t");
      String[] splitTime = splitLine[0].split("\\.");
      Integer seconds = Integer.valueOf(splitTime[0]);
      Integer milliSeconds = Integer.valueOf(splitTime[1]);
      //XMLGregorianCalendar timeZeroCalendar = Tstamp.makeTimestamp(TIME_ZERO);
      //XMLGregorianCalendar timeMilliseconds = Tstamp.incrementMilliseconds(timeZeroCalendar, milliSeconds);
      //XMLGregorianCalendar tStamp = Tstamp.incrementSeconds(timeMilliseconds, seconds);

      // and two double values for the columns
      //
      Double val1 = Double.valueOf(splitLine[1]);
      Double val2 = Double.valueOf(splitLine[2]);

      // format the output
      //
      //String outLine = tStamp.toString() + COMMA + val1.toString() + COMMA + val2.toString();
      String outLine = TIME_ZERO + COMMA + val1.toString() + COMMA + val2.toString();
      out.write(outLine + CR);
    }

    in.close();
    out.close();
  }

  /**
   * Header generator.
   *
   * @return The header as a string.
   */
  private static String getHeader() {
    StringBuffer sb = new StringBuffer(200);
    sb.append("@RELATION ecg" + CR);
    sb.append("@ATTRIBUTE timestamp DATE" + CR);
    sb.append("@ATTRIBUTE value1 REAL" + CR);
    sb.append("@ATTRIBUTE value2 REAL" + CR + CR);
    sb.append("@DATA" + CR);
    return sb.toString();
  }

}
