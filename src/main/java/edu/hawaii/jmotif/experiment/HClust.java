package edu.hawaii.jmotif.experiment;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.CosineDistanceMatrix;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.text.cluster.Cluster;
import edu.hawaii.jmotif.text.cluster.HC;
import edu.hawaii.jmotif.text.cluster.LinkageCriterion;
import edu.hawaii.jmotif.timeseries.TSException;

/**
 * Helper-runner for CBF Hierarchical web example test.
 * 
 * @author psenin
 * 
 */
public class HClust {

  // prefix for all of the output
  private static final String DATA = "/home/psenin/tmp/series.csv";

  // SAX parameters to use
  //
  private static final int PAA_SIZE = 10;
  private static final int ALPHABET_SIZE = 8;
  private static final int WINDOW_SIZE = 40;

  // processing strategy to utilize
  //
  private static final SAXCollectionStrategy STRATEGY = SAXCollectionStrategy.NOREDUCTION;

  /**
   * @param args
   * @throws TSException
   * @throws IndexOutOfBoundsException
   * @throws IOException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, TSException, IOException {

    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(DATA);
    System.out.println("trainData classes: " + trainData.size() + ", series length: "
        + trainData.entrySet().iterator().next().getValue().get(0).length);
    for (Entry<String, List<double[]>> e : trainData.entrySet()) {
      System.out.println(" training class: " + e.getKey() + " series: " + e.getValue().size());
    }

    System.out.println("\nParams: WINDOW " + WINDOW_SIZE + ", PAA " + PAA_SIZE + ", ALPHABET "
        + ALPHABET_SIZE + ", Strategy " + STRATEGY + "\n\nDistance matrix:");

    // parameters
    int[] params = new int[4];
    params[0] = WINDOW_SIZE;
    params[1] = PAA_SIZE;
    params[2] = ALPHABET_SIZE;
    params[3] = STRATEGY.index();

    // making bags collection
    List<WordBag> bags = TextUtils.labeledSeries2WordBags(trainData, params);

    // create the TFIDF data structure
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
    tfidf = TextUtils.normalizeToUnitVectors(tfidf);

    // launch KMeans with random centers
    Cluster clusters = HC.Hc(tfidf, LinkageCriterion.COMPLETE);

    System.out.println((new CosineDistanceMatrix(tfidf)).toString());
    
    System.out.println(TextUtils.tfidfToTable(tfidf));

    BufferedWriter bw = new BufferedWriter(new FileWriter("/home/psenin/tmp/test2.newick"));
    bw.write("(" + clusters.toNewick() + ")");
    bw.close();

  }
}
