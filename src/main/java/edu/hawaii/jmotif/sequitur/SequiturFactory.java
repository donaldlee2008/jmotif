package edu.hawaii.jmotif.sequitur;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.StringTokenizer;
import java.util.TreeSet;
import java.util.concurrent.atomic.AtomicInteger;
import edu.hawaii.jmotif.sax.SAXFactory;
import edu.hawaii.jmotif.sax.alphabet.Alphabet;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.sax.datastructures.SAXFrequencyData;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;

/**
 * Sort of a stand-alone factory to digesting strings with Sequitur.
 * 
 * @author psenin
 * 
 */
public class SequiturFactory {

  private static final double NORMALIZATION_THRESHOLD = 0.005;

  /** Alphabet instance we'll use. */
  private static final Alphabet normalA = new NormalAlphabet();

  /**
   * Digests a string of symbols separated by space.
   * 
   * @param string The string to digest. Symbols expected to be separated by space.
   * 
   * @return The top rule handler.
   */
  public static synchronized SAXRule digest(String string) {

    // clear global collections
    //
    SAXSymbol.theDigrams.clear();
    SAXRule.numRules = new AtomicInteger(0);
    SAXRule.indexes = new TreeSet<Integer>();
    // SAXRule.arrayRuleStrings = new ArrayList<String>();
    SAXRule.arrSAXRuleRecords = new ArrayList<SAXRuleRecord>();

    // init the top-level rule
    //
    SAXRule resRule = new SAXRule();

    // tokenize the input string
    //
    StringTokenizer st = new StringTokenizer(string, " ");

    // while there are tokens
    int currentPosition = 0;
    while (st.hasMoreTokens()) {

      String token = st.nextToken();
      // System.out.println(token);
      // extract next token
      SAXTerminal symbol = new SAXTerminal(token, currentPosition);

      // append to the end of the current sequitur string
      // ... As each new input symbol is observed, append it to rule S....
      resRule.last().insertAfter(symbol);

      // once appended, check if the resulting digram is new or recurrent
      //
      // ... Each time a link is made between two symbols if the new
      // digram is repeated elsewhere
      // and the repetitions do not overlap, if the other occurrence is a
      // complete rule,
      // replace the new digram with the non-terminal symbol that heads
      // the rule,
      // otherwise,form a new rule and replace both digrams with the new
      // non-terminal symbol
      // otherwise, insert the digram into the index...
      resRule.last().p.check();
      currentPosition++;
    }

    return resRule;
  }

  public static List<WordBag> labeledSeries2WordBags(Map<String, List<double[]>> data, int paaSize,
      int alphabetSize, int windowSize, SAXCollectionStrategy strategy)
      throws IndexOutOfBoundsException, TSException {

    int[] params = new int[4];
    params[0] = windowSize;
    params[1] = paaSize;
    params[2] = alphabetSize;
    params[3] = strategy.index();

    // make a map of resulting bags
    Map<String, WordBag> preRes = new HashMap<String, WordBag>();

    // int counter = 0;
    // process series one by one building word bags
    for (Entry<String, List<double[]>> e : data.entrySet()) {

      String classLabel = e.getKey();
      WordBag bag = new WordBag(classLabel);

      for (double[] series : e.getValue()) {
        // System.out.println(counter);
        WordBag cb = seriesToWordBag("tmp", series, params);
        // System.out.println(cb.toString());
        bag.mergeWith(cb);
        // counter++;
      }

      preRes.put(classLabel, bag);
    }

    List<WordBag> res = new ArrayList<WordBag>();
    res.addAll(preRes.values());
    return res;
  }

  private static synchronized WordBag seriesToWordBag(String label, double[] series, int[] params)
      throws IndexOutOfBoundsException, TSException {

    // the result
    WordBag resultBag = new WordBag(label);

    // parameters
    int windowSize = params[0];
    int paaSize = params[1];
    int alphabetSize = params[2];
    SAXCollectionStrategy strategy = SAXCollectionStrategy.fromValue(params[3]);

    // the SAX data structure
    SAXFrequencyData saxFrequencyData = new SAXFrequencyData();

    // need for numerosity reduction
    String previousString = "";

    // scan across the time series extract sub sequences, and convert
    // them to strings
    for (int i = 0; i < series.length - (windowSize - 1); i++) {

      // fix the current subsection
      double[] subSection = Arrays.copyOfRange(series, i, i + windowSize);

      // Z normalize it
      if (TSUtils.stDev(subSection) > NORMALIZATION_THRESHOLD) {
        subSection = TSUtils.zNormalize(subSection);
      }

      // perform PAA conversion if needed
      double[] paa = TSUtils.optimizedPaa(subSection, paaSize);

      // Convert the PAA to a string.
      char[] currentString = TSUtils.ts2String(paa, normalA.getCuts(alphabetSize));

      if (SAXCollectionStrategy.CLASSIC.equals(strategy)) {
        if (previousString.length() > 0
            && SAXFactory.strDistance(currentString, previousString.toCharArray()) == 0) {
          continue;
        }
      }
      else if (SAXCollectionStrategy.EXACT.equals(strategy)) {
        if (previousString.equalsIgnoreCase(String.valueOf(currentString))) {
          continue;
        }
      }

      previousString = String.valueOf(currentString);

      saxFrequencyData.put(new String(currentString), i);

    }

    SAXRule rule = SequiturFactory.digest(saxFrequencyData.getSAXString(" "));

    ArrayList<SAXRuleRecord> expandedRules = rule.getSAXRules();
    for (SAXRuleRecord r : expandedRules) {
      if (0 == r.getRuleFrequency()) {
        continue;
      }
      resultBag.addWord(r.getExpandedRuleString(), r.getRuleFrequency());
    }

    String displayString = rule.getGrammarDisplayString();
    StringTokenizer st = new StringTokenizer(displayString, " ");
    // while there are tokens
    while (st.hasMoreTokens()) {
      String token = st.nextToken();
      if (token.startsWith("R")) {
        continue;
      }
      resultBag.addWord(token);
    }

    return resultBag;
  }

  public static int classify(String classKey, double[] series,
      HashMap<String, HashMap<String, Double>> tfidf, int paaSize, int alphabetSize,
      int windowSize, SAXCollectionStrategy strategy) throws IndexOutOfBoundsException, TSException {

    int[] params = new int[4];
    params[0] = windowSize;
    params[1] = paaSize;
    params[2] = alphabetSize;
    params[3] = strategy.index();

    WordBag test = seriesToWordBag("test", series, params);

    // it is Cosine similarity,
    //
    // which ranges from 0.0 for the angle of 90 to 1.0 for the angle of 0
    // i.e. LARGES value is a SMALLEST distance
    double minDist = Double.MIN_VALUE;
    String className = "";
    double[] cosines = new double[tfidf.entrySet().size()];

    int index = 0;
    for (Entry<String, HashMap<String, Double>> e : tfidf.entrySet()) {

      double dist = TextUtils.cosineSimilarity(test, e.getValue());
      cosines[index] = dist;
      index++;

      if (dist > minDist) {
        className = e.getKey();
        minDist = dist;
      }
    }
    // sometimes, due to the VECTORs specific layout, all values are the same, NEED to take care
    boolean allEqual = true;
    double cosine = cosines[0];
    for (int i = 1; i < cosines.length; i++) {
      if (!(cosines[i] == cosine)) {
        allEqual = false;
      }
    }

    // report our findings
    if (!(allEqual) && className.equalsIgnoreCase(classKey)) {
      return 1;
    }

    // System.out.println("all equal " + allEqual + ", assigned to " + className + " instead of " +
    // classKey);

    return 0;
  }

}
