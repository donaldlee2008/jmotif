package edu.hawaii.jmotif.webexample;

import weka.core.Instances;
import weka.core.converters.ConverterUtils.DataSource;
import edu.hawaii.jmotif.sax.LargeWindowAlgorithm;
import edu.hawaii.jmotif.sax.SAXFactory;
import edu.hawaii.jmotif.sax.datastructures.DiscordsAndMotifs;

/**
 * The discords experiment code. see the example on the web and more detailed description in the
 * Keogh's article.
 * 
 * @author Pavel Senin.
 * 
 */
public class MotifsDiscordsExample {

  private static final int windowSize = 150;

  private static final int alphabetSize = 6;

  /**
   * The main executable method.
   * 
   * @param args None used.
   * @throws Exception if error occurs.
   */
  public static void main(String[] args) throws Exception {

    Instances tsData = readTSData();

    DiscordsAndMotifs dr = SAXFactory.series2DiscordsAndMotifs(toDoubleSeries(tsData), windowSize,
        alphabetSize, 2, 2, new LargeWindowAlgorithm());

    System.out.println("\n\n\n" + dr.toString());

  }

  private static double[] toDoubleSeries(Instances tsData) {
    int window = 3000;
    int offset = 4779;
    double[] res = new double[window];
    for (int idx = 0; idx < window; idx++) {
      res[idx] = tsData.instance(idx + offset).value(1);
      if (idx >= window + offset) {
        break;
      }
    }
    return res;
  }

  /**
   * Data reader.
   * 
   * @return timeseries read from file.
   * @throws Exception if error occurs.
   */
  private static Instances readTSData() throws Exception {
    // Instances data = DataSource.read("data//ts_data//mitdbx_mitdbx_108.arff");
    Instances data = DataSource.read("data//ts_data//qtdbsele0606.arff");
    return data;
  }

}
