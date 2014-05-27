package edu.hawaii.jmotif.experiment.synthetic;

import java.io.IOException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.sax.alphabet.Alphabet;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.text.cluster.RandomStartStrategy;
import edu.hawaii.jmotif.text.cluster.TextKMeans;
import edu.hawaii.jmotif.timeseries.TSException;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class TestEDKMeans {

  protected final static int CLASSIC = 0;
  protected final static int EXACT = 1;
  protected final static int NOREDUCTION = 2;

  // string constants
  private static final String COMMA = ",";

  // prefix for all of the output
  private static final String PREFIX = "data/ElectricDevices/";

  // various variables
  private final static Alphabet a = new NormalAlphabet();
  private static final DecimalFormat df = new DecimalFormat("#0.0000000000");

  // SAX parameters to use
  //
  private static final int[][] params = { { 17, 13, 5, NOREDUCTION } };

  private static final Integer NUM_CLUSTERS = 7;

  /**
   * @param args
   * @throws TSException
   * @throws IndexOutOfBoundsException
   * @throws IOException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, TSException, IOException {

    int[][] p = new int[1][4];
    p[0][0] = params[0][0];
    p[0][1] = params[0][1];
    p[0][2] = params[0][2];
    SAXCollectionStrategy strategy = SAXCollectionStrategy.CLASSIC;
    if (EXACT == params[0][3]) {
      strategy = SAXCollectionStrategy.EXACT;
    }
    else if (NOREDUCTION == params[0][3]) {
      strategy = SAXCollectionStrategy.NOREDUCTION;
    }

    p[0][3] = strategy.index();

    // get the data loaded into memory
    //
    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(PREFIX + "ElectricDevices_TRAIN");
    List<double[]> zeroes = trainData.get("0");
    System.out.println("Zeroes: " + zeroes.size());

    List<WordBag> bags = new ArrayList<WordBag>();

    int setSize = 5;
    bags.addAll(getSeries(trainData, "0", "TV", setSize, p));
    bags.addAll(getSeries(trainData, "1", "D", setSize, p));
    bags.addAll(getSeries(trainData, "2", "C", setSize, p));
    bags.addAll(getSeries(trainData, "3", "I", setSize, p));
    bags.addAll(getSeries(trainData, "4", "K", setSize, p));
    bags.addAll(getSeries(trainData, "5", "O", setSize, p));
    bags.addAll(getSeries(trainData, "6", "W", setSize, p));

    // create the TFIDF data structure
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);
    tfidf = TextUtils.normalizeToUnitVectors(tfidf);

    // launch KMeans with random centers
    // Cluster clusters = HC.Hc(tfidf, LinkageCriterion.SINGLE);
    //
    // BufferedWriter bw = new BufferedWriter(new FileWriter(PREFIX + "test.newick"));
    // bw.write("(" + clusters.toNewick() + ")");
    // bw.close();

    // launch KMeans with random centers
    HashMap<String, List<String>> clusters = TextKMeans.cluster(tfidf, NUM_CLUSTERS,
        new RandomStartStrategy());

  }

  private static Collection<WordBag> getSeries(Map<String, List<double[]>> trainData, String label,
      String prefix, int num, int[][] p) throws IndexOutOfBoundsException, TSException {
    List<double[]> set = trainData.get(label);
    Collection<WordBag> wb = new ArrayList<WordBag>();
    for (int i = 0; i < num; i++) {
      wb.add(TextUtils.seriesToWordBag(prefix + String.valueOf(i), set.get(i), p[0]));
    }
    return wb;
  }
}
