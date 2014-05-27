package edu.hawaii.jmotif.performance.digits;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.Callable;
import edu.hawaii.jmotif.algorithm.MatrixFactory;
import edu.hawaii.jmotif.performance.KNNStackEntry;
import edu.hawaii.jmotif.sax.SAXFactory;
import edu.hawaii.jmotif.sax.alphabet.Alphabet;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.timeseries.TSException;

public class DigitsConfusionJob implements Callable<String> {

  private Map<String, WordBag> bags;
  private int[] params;
  private double[] series;
  private int seriesCounter;

  public DigitsConfusionJob(double[] series, int seriesCounter, Map<String, WordBag> bags, int[] p) {
    this.series = series;
    this.bags = bags;
    this.params = p;
    this.seriesCounter = seriesCounter;
  }

  @Override
  public String call() throws Exception {
    return getVotes(getNeighbors(
        seriesToWordBag("test", subseries(this.series, 1, 784), this.params,
            SAXCollectionStrategy.NOREDUCTION), this.bags, this.params));
  }

  private String getVotes(List<KNNStackEntry<String, Double>> neighbors) {
    String[] res = new String[neighbors.size()];
    int i = 0;
    for (KNNStackEntry<String, Double> e : neighbors) {
      res[i] = e.getKey();
      i++;
    }
    return "ok_ " + Arrays.toString(res) + " : " + seriesCounter + "," + getVote(res) + ","
        + res[9];
  }

  private int getVote(String[] res) {
    int[] votes = new int[10];
    for (String s : res) {
      votes[Integer.valueOf(s)]++;
    }
    int maxVotes = -1;
    int maxIdx = 0;
    for (int i = 0; i < 10; i++) {
      if (votes[i] > maxVotes) {
        maxVotes = votes[i];
        maxIdx = i;
      }
    }
    return maxIdx;
  }

  private ArrayList<KNNStackEntry<String, Double>> getNeighbors(WordBag test,
      Map<String, WordBag> bags, int[] p) {
    ArrayList<KNNStackEntry<String, Double>> res = new ArrayList<KNNStackEntry<String, Double>>();
    for (WordBag b : bags.values()) {
      double dist = getDist(test, b);
      if (res.size() < 10) {
        res.add(new KNNStackEntry<String, Double>(b.getLabel(), dist));
      }
      else {
        checkDist(res, b, dist);
      }
    }
    return res;
  }

  private void checkDist(ArrayList<KNNStackEntry<String, Double>> res, WordBag b, double dist) {
    Collections.sort(res, new Comparator<KNNStackEntry<String, Double>>() {
      @Override
      public int compare(KNNStackEntry<String, Double> arg0, KNNStackEntry<String, Double> arg1) {
        return arg0.getValue().compareTo(arg1.getValue());
      }
    });

    if (res.get(0).getValue() < dist) {
      res.remove(0);
      res.add(new KNNStackEntry<String, Double>(b.getLabel(), dist));
    }

  }

  private double getDist(WordBag bagA, WordBag bagB) {

    HashSet<String> allWords = new HashSet<String>();
    allWords.addAll(bagA.getInternalWords().keySet());
    allWords.addAll(bagB.getInternalWords().keySet());

    HashMap<String, Double> a = new HashMap<String, Double>();
    HashMap<String, Double> b = new HashMap<String, Double>();
    for (String word : allWords) {

      if (bagA.contains(word)) {
        a.put(word, bagA.getInternalWords().get(word).doubleValue());
      }
      else {
        a.put(word, 0.);
      }

      if (bagB.contains(word)) {
        b.put(word, bagB.getInternalWords().get(word).doubleValue());
      }
      else {
        b.put(word, 0.);
      }

    }
    return cosineDistance(a, b);
  }

  public double cosineDistance(HashMap<String, Double> data1, HashMap<String, Double> data2) {
    // sanity word order check
    if (!(data2.keySet().containsAll(data1.keySet()))
        || !(data2.keySet().size() == data1.keySet().size())) {
      throw new RuntimeException("COSINE SIMILARITY ERROR: word sets are different in length!");
    }

    double[] vector1 = new double[data1.size()];
    double[] vector2 = new double[data2.size()];

    int i = 0;
    for (String s : data1.keySet()) {
      vector1[i] = data1.get(s);
      vector2[i] = data2.get(s);
      i++;
    }

    double numerator = dotProduct(vector1, vector2);
    double denominator = magnitude(vector1) * magnitude(vector2);

    return numerator / denominator;
  }

  /**
   * Compute the magnitude of the vector.
   * 
   * @param vector The vector.
   * @return The magnitude.
   */
  public double magnitude(double[] vector) {
    return Math.sqrt(dotProduct(vector, vector));
  }

  /**
   * Compute the dot product of two vectors.
   * 
   * @param vector1 The vector 1.
   * @param vector2 The vector 2.
   * @return The dot product.
   */
  public static synchronized double dotProduct(double[] vector1, double[] vector2) {
    double res = 0.0D;
    for (int i = 0; i < vector1.length; i++) {
      res = res + vector1[i] * vector2[i];
    }
    return res;
  }

  /** The latin alphabet, lower case letters a-z. */
  private static final char[] ALPHABET = { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
      'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' };

  private static final String COMMA = ",";

  private WordBag seriesToWordBag(String label, double[] series, int[] params,
      SAXCollectionStrategy strategy) throws IndexOutOfBoundsException, TSException {

    Alphabet a = new NormalAlphabet();

    WordBag resultBag = new WordBag(label);

    int windowSize = params[0];
    int paaSize = params[1];
    int alphabetSize = params[2];

    String oldStr = "";
    for (int i = 0; i <= series.length - windowSize; i++) {

      double[] paa = paa(zNormalize(subseries(series, i, windowSize)), paaSize);

      char[] sax = ts2String(paa, a.getCuts(alphabetSize));

      if (SAXCollectionStrategy.CLASSIC.equals(strategy)) {
        if (oldStr.length() > 0 && SAXFactory.strDistance(sax, oldStr.toCharArray()) == 0) {
          continue;
        }
      }
      else if (SAXCollectionStrategy.EXACT.equals(strategy)) {
        if (oldStr.equalsIgnoreCase(String.valueOf(sax))) {
          continue;
        }
      }

      oldStr = String.valueOf(sax);

      resultBag.addWord(String.valueOf(sax));
    }

    return resultBag;
  }

  private double cosineSimilarity(WordBag testSample, HashMap<String, Double> weightVector) {
    double res = 0;
    for (Entry<String, Integer> entry : testSample.getWords().entrySet()) {
      if (weightVector.containsKey(entry.getKey())) {
        res = res + entry.getValue().doubleValue() * weightVector.get(entry.getKey()).doubleValue();
      }
    }
    double m1 = magnitude(testSample.getWordsAsDoubles().values());
    double m2 = magnitude(weightVector.values());
    return res / (m1 * m2);
  }

  private double magnitude(Collection<Double> values) {
    double res = 0.0D;
    for (Double v : values) {
      res = res + v * v;
    }
    return Math.sqrt(res);
  }

  /**
   * Approximate the timeseries using PAA. If the timeseries has some NaN's they are handled as
   * follows: 1) if all values of the piece are NaNs - the piece is approximated as NaN, 2) if there
   * are some (more or equal one) values happened to be in the piece - algorithm will handle it as
   * usual - getting the mean.
   * 
   * @param ts The timeseries to approximate.
   * @param paaSize The desired length of approximated timeseries.
   * @return PAA-approximated timeseries.
   * @throws TSException if error occurs.
   */
  private double[] paa(double[] ts, int paaSize) throws TSException {
    // fix the length
    int len = ts.length;
    // check for the trivial case
    if (len == paaSize) {
      return Arrays.copyOf(ts, ts.length);
    }
    else {
      if (len % paaSize == 0) {
        return MatrixFactory.colMeans(MatrixFactory.reshape(asMatrix(ts), len / paaSize, paaSize));
      }
      else {
        // res = new double[len][paaSize];
        // for (int j = 0; j < len; j++) {
        // for (int i = 0; i < paaSize; i++) {
        // int idx = j * paaSize + i;
        // int row = idx % len;
        // int col = idx / len;
        // res[row][col] = ts[j];
        // }
        // }
        double[] paa = new double[paaSize];
        for (int i = 0; i < len * paaSize; i++) {
          int idx = i / len; // the spot
          int pos = i / paaSize; // the col spot
          paa[idx] = paa[idx] + ts[pos];
        }
        for (int i = 0; i < paaSize; i++) {
          paa[i] = paa[i] / (double) len;
        }
        return paa;
      }
    }

  }

  /**
   * Mimics Matlab function for reshape: returns the m-by-n matrix B whose elements are taken
   * column-wise from A. An error results if A does not have m*n elements.
   * 
   * @param a the source matrix.
   * @param n number of rows in the new matrix.
   * @param m number of columns in the new matrix.
   * 
   * @return reshaped matrix.
   */
  private double[][] reshape(double[][] a, int n, int m) {
    int cEl = 0;
    int aRows = a.length;

    double[][] res = new double[n][m];

    for (int j = 0; j < m; j++) {
      for (int i = 0; i < n; i++) {
        res[i][j] = a[cEl % aRows][cEl / aRows];
        cEl++;
      }
    }

    return res;
  }

  /**
   * Computes column means for the matrix.
   * 
   * @param a the input matrix.
   * @return result.
   */
  private double[] colMeans(double[][] a) {
    double[] res = new double[a[0].length];
    for (int j = 0; j < a[0].length; j++) {
      double sum = 0;
      for (int i = 0; i < a.length; i++) {
        sum += a[i][j];
      }
      // res[j] = sum / ((Integer) a.length).doubleValue();
      res[j] = sum / ((double) a.length);
    }
    return res;
  }

  /**
   * Converts the vector into one-row matrix.
   * 
   * @param vector The vector.
   * @return The matrix.
   */
  private double[][] asMatrix(double[] vector) {
    double[][] res = new double[1][vector.length];
    for (int i = 0; i < vector.length; i++) {
      res[0][i] = vector[i];
    }
    return res;
  }

  /**
   * Z-Normalize timeseries to the mean zero and standard deviation of one.
   * 
   * @param series The timeseries.
   * @return Z-normalized time-series.
   * @throws TSException if error occurs.
   */
  private double[] zNormalize(double[] series) throws TSException {

    // this is the resulting normalization
    //
    double[] res = new double[series.length];

    // get mean and sdev, NaN's will be handled
    //
    double mean = mean(series);
    double sd = stDev(series);

    // another special case, where SD happens to be close to a zero, i.e. they all are the same for
    // example
    //
    if (sd <= 0.001D) {

      // here I assign another magic value - 0.001D which makes to middle band of the normal
      // Alphabet
      //
      for (int i = 0; i < res.length; i++) {
        if (Double.isInfinite(series[i]) || Double.isNaN(series[i])) {
          res[i] = series[i];
        }
        else {
          res[i] = 0.1D;
        }
      }
    }

    // normal case, everything seems to be fine
    //
    else {
      // sd and mean here, - go-go-go
      for (int i = 0; i < res.length; i++) {
        res[i] = (series[i] - mean) / sd;
      }
    }
    return res;

  }

  /**
   * Computes the mean value of timeseries.
   * 
   * @param series The timeseries.
   * @return The mean value.
   */
  private double mean(double[] series) {
    double res = 0D;
    int count = 0;
    for (double tp : series) {
      if (Double.isNaN(tp) || Double.isInfinite(tp)) {
        continue;
      }
      else {
        res += tp;
        count += 1;
      }
    }
    if (count > 0) {
      return res / ((Integer) count).doubleValue();
    }
    return Double.NaN;
  }

  /**
   * Computes the standard deviation of timeseries.
   * 
   * @param series The timeseries.
   * @return the standard deviation.
   */
  private double stDev(double[] series) {
    double num0 = 0D;
    double sum = 0D;
    int count = 0;
    for (double tp : series) {
      if (Double.isNaN(tp) || Double.isInfinite(tp)) {
        continue;
      }
      else {
        num0 = num0 + tp * tp;
        sum = sum + tp;
        count += 1;
      }
    }
    if (count > 0) {
      double len = ((Integer) count).doubleValue();
      return Math.sqrt((len * num0 - sum * sum) / (len * (len - 1)));
    }
    return Double.NaN;
  }

  /**
   * Extract subseries out of series.
   * 
   * @param series The series array.
   * @param start Start position
   * @param length Length of subseries to extract.
   * @return The subseries.
   * @throws IndexOutOfBoundsException If error occurs.
   */
  private double[] subseries(double[] series, int start, int length)
      throws IndexOutOfBoundsException {
    if (start + length > series.length) {
      throw new IndexOutOfBoundsException("Unable to extract subseries, series length: "
          + series.length + ", start: " + start + ", subseries length: " + length);
    }
    double[] res = new double[length];
    for (int i = 0; i < length; i++) {
      res[i] = series[start + i];
    }
    return res;
  }

  /**
   * Converts the timeseries into string using given cuts intervals. Useful for not-normal
   * distribution cuts.
   * 
   * @param vals The timeseries.
   * @param cuts The cut intervals.
   * @return The timeseries SAX representation.
   */
  private char[] ts2String(double[] vals, double[] cuts) {
    char[] res = new char[vals.length];
    for (int i = 0; i < vals.length; i++) {
      res[i] = num2char(vals[i], cuts);
    }
    return res;
  }

  /**
   * Get mapping of a number to char.
   * 
   * @param value the value to map.
   * @param cuts the array of intervals.
   * @return character corresponding to numeric value.
   */
  private char num2char(double value, double[] cuts) {
    int count = 0;
    while ((count < cuts.length) && (cuts[count] <= value)) {
      count++;
    }
    return ALPHABET[count];
  }
}
