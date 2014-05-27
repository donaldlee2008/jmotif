package edu.hawaii.jmotif.experiment.clustering;

import java.io.IOException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import cc.mallet.util.Randoms;
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
public class TestPhysioKMeans {

  protected final static int CLASSIC = 0;
  protected final static int EXACT = 1;
  protected final static int NOREDUCTION = 2;

  // string constants
  private static final String COMMA = ",";

  // prefix for all of the output
  private static final String DATA = "physio/PHYSIO_CLUSTER.csv";

  // various variables
  private final static Alphabet a = new NormalAlphabet();
  private static final DecimalFormat df = new DecimalFormat("#0.0000000000");

  // SAX parameters to use
  //
  private static final int[][] params = { { 51, 10, 10, EXACT } };

  private static final String[] keys = { "II", "AVR", "RESP", "PLETH", "CO2" };

  private static final int[] key2 = { 1449, 235, 1058, 668, 1310, 230, 501, 865, 551, 700, 1077,
      1242, 528, 1107, 881, 314, 483, 234, 1475, 725 };
  // [1] "II_1449" "II_235" "II_1058" "II_668" "II_1310" "II_230" "II_501" "II_865"
  // [9] "II_551" "II_700" "II_1077" "II_1242" "II_528" "II_1107" "II_881" "II_314"
  // [17] "II_483" "II_234" "II_1475" "II_725"

  private static final int[] keyV = { 1212, 164, 141, 998, 720, 357, 1019, 455, 481, 739, 880,
      1136, 1222, 492, 406, 654, 834, 1500, 1116, 1116 };
  // [1] "V_1212" "V_164" "V_141" "V_998" "V_720" "V_357" "V_1019" "V_455" "V_481"
  // [10] "V_739" "V_880" "V_1136" "V_1222" "V_492" "V_406" "V_654" "V_834"
  // [19] "V_1500" "V_1116" "V_1116"

  private static final int[] keyRESP = { 793, 224, 1111, 774, 1148, 1091, 1167, 764, 593, 177, 612,
      1011, 231, 701, 565, 279, 246, 359, 1376, 149 };
  // [1] "RESP_793" "RESP_224" "RESP_1111" "RESP_774" "RESP_1148" "RESP_1091" "RESP_1167"
  // [8] "RESP_764" "RESP_593" "RESP_177" "RESP_612" "RESP_1011" "RESP_231" "RESP_701"
  // [15] "RESP_565" "RESP_279" "RESP_246" "RESP_359" "RESP_1376" "RESP_149"

  private static final int[] keyPLETH = { 189, 82, 926, 13, 1005, 1220, 539, 1328, 958, 337, 226,
      640, 755, 931, 549, 905, 171, 567, 891, 1398 };
  // [1] "PLETH_189" "PLETH_82" "PLETH_926" "PLETH_13" "PLETH_1005" "PLETH_1220"
  // [7] "PLETH_539" "PLETH_1328" "PLETH_958" "PLETH_337" "PLETH_226" "PLETH_640"
  // [13] "PLETH_755" "PLETH_931" "PLETH_549" "PLETH_905" "PLETH_171" "PLETH_567"
  // [19] "PLETH_891" "PLETH_1398"

  private static final int[] keyAVR = { 744, 681, 1038, 865, 855, 927, 1187, 814, 938, 88, 1012,
      716, 370, 1162, 923, 1361, 1368, 169, 1242, 1147 };
  // "AVR_744" "AVR_681" "AVR_1038" "AVR_865" "AVR_855" "AVR_927" "AVR_1187"
  // "AVR_814" "AVR_938" "AVR_88" "AVR_1012" "AVR_716" "AVR_370" "AVR_1162"
  // "AVR_923" "AVR_1361" "AVR_1368" "AVR_169" "AVR_1242" "AVR_1147"

  private static final int[] keyCO2 = { 467, 77, 161, 312, 408, 239, 1, 383, 264, 143, 423, 443,
      58, 428, 183, 276, 416, 11, 334, 365 };

  private static final Integer NUM_CLUSTERS = 5;
  private static final Integer NUM_REPEATS = 10;
  private static final int NUM_SAMPLES = 15;
  private static Randoms randoms;

  /**
   * @param args
   * @throws TSException
   * @throws IndexOutOfBoundsException
   * @throws IOException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, TSException, IOException {

    randoms = new Randoms();

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
    Map<String, List<double[]>> trainData = UCRUtils.readUCRData(DATA);
    List<double[]> zeroes = trainData.get(keys[0]);
    System.out.println("Zeroes: " + zeroes.size());

    for (int repeat = 0; repeat < NUM_REPEATS; repeat++) {

      System.out.println("REPEAT " + repeat + " OUT OF " + NUM_REPEATS);

      List<WordBag> bags = new ArrayList<WordBag>();

      bags.addAll(getSeries(trainData, keys[0], key2, p));
      bags.addAll(getSeries(trainData, keys[1], keyAVR, p));
      bags.addAll(getSeries(trainData, keys[2], keyRESP, p));
      bags.addAll(getSeries(trainData, keys[3], keyPLETH, p));
      bags.addAll(getSeries(trainData, keys[4], keyCO2, p));

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
  }

  private static Collection<? extends WordBag> getSeries(Map<String, List<double[]>> trainData,
      String label, int[] indexes, int[][] p) throws IndexOutOfBoundsException, TSException {
    List<double[]> set = trainData.get(label);
    Collection<WordBag> wb = new ArrayList<WordBag>();
    for (int i : indexes) {
      wb.add(TextUtils.seriesToWordBag(label + "_" + String.valueOf(i - 1), set.get(i - 1), p[0]));
    }
    return wb;
  }

  private static Collection<WordBag> getSeries(Map<String, List<double[]>> trainData, String label,
      String prefix2, int[] is, int[][] p) throws IndexOutOfBoundsException, TSException {
    List<double[]> set = trainData.get(label);
    Collection<WordBag> wb = new ArrayList<WordBag>();
    for (int i : is) {
      wb.add(TextUtils.seriesToWordBag(prefix2 + String.valueOf(i - 1), set.get(i), p[0]));
    }
    return wb;
  }

  private static Collection<WordBag> getSeries(Map<String, List<double[]>> trainData, String label,
      String prefix, int num, int[][] p) throws IndexOutOfBoundsException, TSException {
    List<double[]> set = trainData.get(label);
    Collection<WordBag> wb = new ArrayList<WordBag>();
    for (int i = 0; i < num; i++) {
      int idx = randoms.nextInt(set.size());
      wb.add(TextUtils.seriesToWordBag(prefix + "_" + String.valueOf(idx), set.get(idx), p[0]));
    }
    return wb;
  }
}
