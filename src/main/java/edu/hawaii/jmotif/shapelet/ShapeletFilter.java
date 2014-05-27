package edu.hawaii.jmotif.shapelet;

/*
 * NOTE: As shapelet extraction can be time consuming, there is an option to output shapelets
 * to a text file (Default location is in the root dir of the project, file name "defaultShapeletOutput.txt").
 *
 * Default settings are TO PRODUCE OUTPUT FILE - unless file name is changed, each successive filter will
 * overwrite the output (see "setLogOutputFile(String fileName)" to change file dir and name).
 *
 * To reconstruct a filter from this output, please see the method "createFilterFromFile(String fileName)".
 */

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Scanner;
import java.util.TreeMap;
import weka.core.Attribute;
import weka.core.FastVector;
import weka.core.Instance;
import weka.core.Instances;
import weka.core.SparseInstance;

public class ShapeletFilter {

  private int minShapeletLength;
  private int maxShapeletLength;
  private int numShapelets;
  private boolean shapeletsTrained;
  private ArrayList<Shapelet> shapelets;
  private String ouputFileLocation = "defaultShapeletOutput.txt"; // default store location
  private boolean recordShapelets = true; // default action is to write an output file

  public ShapeletFilter() {
    this.minShapeletLength = -1;
    this.maxShapeletLength = -1;
    this.numShapelets = -1;
    this.shapeletsTrained = false;
    this.shapelets = null;
  }

  /**
   * 
   * @param k - the number of shapelets to be generated
   */
  public ShapeletFilter(int k) {
    this.minShapeletLength = -1;
    this.maxShapeletLength = -1;
    this.numShapelets = k;
    this.shapelets = new ArrayList<Shapelet>();
    this.shapeletsTrained = false;
  }

  /**
   * 
   * @param k - the number of shapelets to be generated
   * @param minShapeletLength - minimum length of shapelets
   * @param maxShapeletLength - maximum length of shapelets
   */
  public ShapeletFilter(int k, int minShapeletLength, int maxShapeletLength) {
    this.minShapeletLength = minShapeletLength;
    this.maxShapeletLength = maxShapeletLength;
    this.numShapelets = k;
    this.shapelets = new ArrayList<Shapelet>();
    this.shapeletsTrained = false;
  }

  /**
   * 
   * @param k - the number of shapelets to be generated
   */
  public void setNumberOfShapelets(int k) {
    this.numShapelets = k;
  }

  /**
   * 
   * @param minShapeletLength - minimum length of shapelets
   * @param maxShapeletLength - maximum length of shapelets
   */
  public void setShapeletMinAndMax(int minShapeletLength, int maxShapeletLength) {
    this.minShapeletLength = minShapeletLength;
    this.maxShapeletLength = maxShapeletLength;
  }

  /**
   * 
   * @param inputFormat - the format of the input data
   * @return a new Instances object in the desired output format
   * @throws Exception - if all required attributes of the filter are not initialised correctly
   */
  protected Instances determineOutputFormat(Instances inputFormat) throws Exception {

    if (this.numShapelets < 1) {
      throw new Exception(
          "ShapeletFilter not initialised correctly - please specify a value of k that is greater than 1");
    }

    // Set up instances size and format.
    int length = this.numShapelets;
    FastVector<Attribute> atts = new FastVector();
    String name;
    for (int i = 0; i < length; i++) {
      name = "Shapelet_" + i;
      atts.addElement(new Attribute(name));
    }

    if (inputFormat.classIndex() >= 0) { // Classification set, set class
      // Get the class values as a fast vector
      Attribute target = inputFormat.attribute(inputFormat.classIndex());

      FastVector vals = new FastVector(target.numValues());
      for (int i = 0; i < target.numValues(); i++) {
        vals.addElement(target.value(i));
      }
      atts.addElement(new Attribute(inputFormat.attribute(inputFormat.classIndex()).name(), vals));
    }
    Instances result = new Instances("Shapelets" + inputFormat.relationName(), atts,
        inputFormat.numInstances());
    if (inputFormat.classIndex() >= 0) {
      result.setClassIndex(result.numAttributes() - 1);
    }
    return result;
  }

  /**
   * 
   * @param data - the input data to be transformed (and to find the shapelets if this is the first
   * run)
   * @return the transformed Instances in terms of the distance from each shapelet
   * @throws Exception - if the number of shapelets or the length parameters specified are incorrect
   */
  public Instances process(Instances data) throws Exception {
    if (this.numShapelets < 1) {
      throw new Exception(
          "Number of shapelets initialised incorrectly - please select value of k (Usage: setNumberOfShapelets");
    }

    int maxPossibleLength;
    if (data.classIndex() < 0)
      maxPossibleLength = data.instance(0).numAttributes();
    else
      maxPossibleLength = data.instance(0).numAttributes() - 1;

    if (this.minShapeletLength < 1 || this.maxShapeletLength < 1
        || this.maxShapeletLength < this.minShapeletLength
        || this.maxShapeletLength > maxPossibleLength) {
      throw new Exception("Shapelet length parameters initialised incorrectly");
    }

    if (this.shapeletsTrained == false) { // shapelets discovery has not yet been caried out, so do
                                          // so
      this.shapelets = findBestKShapeletsCache(this.numShapelets, data, this.minShapeletLength,
          this.maxShapeletLength); // get k shapelets ATTENTION
      this.shapeletsTrained = true;
      System.out.println(shapelets.size() + " Shapelets have been generated");
    }

    Instances output = determineOutputFormat(data);

    // for each data, get distance to each shapelet and create new instance
    for (int i = 0; i < data.numInstances(); i++) { // for each data
      Instance toAdd = new SparseInstance(this.shapelets.size() + 1);
      int shapeletNum = 0;
      for (Shapelet s : this.shapelets) {
        double dist = subsequenceDistance(s.content, data.instance(i));
        toAdd.setValue(shapeletNum++, dist);
      }
      toAdd.setValue(this.shapelets.size(), data.instance(i).classValue());
      output.add(toAdd);
    }
    return output;
  }

  public void setLogOutputFile(String fileName) {
    this.recordShapelets = true;
    this.ouputFileLocation = fileName;
  }

  public void turnOffLog() {
    this.recordShapelets = false;
  }

  /**
   * 
   * @param numShapelets - the target number of shapelets to generate
   * @param data - the data that the shapelets will be taken from
   * @param minShapeletLength - the minimum length of possible shapelets
   * @param maxShapeletLength - the maximum length of possible shapelets
   * @return an ArrayList of Shapelet objects in order of their fitness (by infoGain, seperationGap
   * then shortest length)
   */
  private ArrayList<Shapelet> findBestKShapeletsCache(int numShapelets, Instances data,
      int minShapeletLength, int maxShapeletLength) throws Exception {

    long startTime = System.nanoTime();

    ArrayList<Shapelet> kShapelets = new ArrayList<Shapelet>(); // store (upto) the best k shapelets
                                                                // overall
    ArrayList<Shapelet> seriesShapelets = new ArrayList<Shapelet>(); // temp store of all shapelets
                                                                     // for each time series

    /*
     * new version to allow caching: - for all time series, calculate the gain of all candidates of
     * all possible lengths - insert into a strucutre in order of fitness - arraylist with
     * comparable implementation of shapelets - once all candidates for a series are established,
     * integrate into store of k best
     */

    TreeMap<Double, Integer> classDistributions = getClassDistributions(data); // used to calc info
                                                                               // gain

    // for all time series
    System.out.println("Processing data: ");
    int numInstances = data.numInstances();
    for (int i = 0; i < numInstances; i++) {

      if (i == 0 || i % (numInstances / 4) == 0) {
        System.out.println("Currently processing instance " + (i + 1) + " of " + numInstances);
      }

      double[] wholeCandidate = data.instance(i).toDoubleArray();
      seriesShapelets = new ArrayList<Shapelet>();

      for (int length = minShapeletLength; length <= maxShapeletLength; length++) {

        // for all possible starting positions of that length
        for (int start = 0; start <= wholeCandidate.length - length - 1; start++) { // -1 = avoid
                                                                                    // classVal -
                                                                                    // handle later
                                                                                    // for series
                                                                                    // with no class
                                                                                    // val
          // CANDIDATE ESTABLISHED - got original series, length and starting position
          // extract relevant part into a double[] for processing
          double[] candidate = new double[length];
          for (int m = start; m < start + length; m++) {
            candidate[m - start] = wholeCandidate[m];
          }

          // znorm candidate here so it's only done once, rather than in each distance calculation
          candidate = zNorm(candidate, false);
          Shapelet candidateShapelet = checkCandidate(candidate, data, i, start, classDistributions);
          seriesShapelets.add(candidateShapelet);
        }
      }
      // now that we have all shapelets, self similarity can be fairly assessed without fear of
      // removing potentially
      // good shapelets
      Collections.sort(seriesShapelets);
      seriesShapelets = removeSelfSimilar(seriesShapelets);
      kShapelets = combine(numShapelets, kShapelets, seriesShapelets);
    }

    if (this.recordShapelets) {
      FileWriter out = new FileWriter(this.ouputFileLocation);
      for (int i = 0; i < kShapelets.size(); i++) {
        out.append(kShapelets.get(i).informationGain + "," + kShapelets.get(i).seriesId + ","
            + kShapelets.get(i).startPos + "\n");

        double[] shapeletContent = kShapelets.get(i).content;
        for (int j = 0; j < shapeletContent.length; j++) {
          out.append(shapeletContent[j] + ",");
        }
        out.append("\n");
      }
      out.close();
    }
    System.out.println();
    System.out.println("Output Shapelets:");
    System.out.println("-------------------");
    System.out.println("informationGain,seriesId,startPos");
    System.out.println("<shapelet>");
    System.out.println("-------------------");
    System.out.println();
    for (int i = 0; i < kShapelets.size(); i++) {
      System.out.println(kShapelets.get(i).informationGain + "," + kShapelets.get(i).seriesId + ","
          + kShapelets.get(i).startPos);
      double[] shapeletContent = kShapelets.get(i).content;
      for (int j = 0; j < shapeletContent.length; j++) {
        System.out.print(shapeletContent[j] + ",");
      }
      System.out.println();
    }

    return kShapelets;
  }

  /**
   * 
   * @param shapelets the input Shapelets to remove self similar Shapelet objects from
   * @return a copy of the input ArrayList with self-similar shapelets removed
   */
  private static ArrayList<Shapelet> removeSelfSimilar(ArrayList<Shapelet> shapelets) {
    // return a new pruned array list - more efficient than removing
    // self-similar entries on the fly and constantly reindexing
    ArrayList<Shapelet> outputShapelets = new ArrayList<Shapelet>();
    boolean[] selfSimilar = new boolean[shapelets.size()];

    // to keep track of self similarity - assume nothing is similar to begin with
    for (int i = 0; i < shapelets.size(); i++) {
      selfSimilar[i] = false;
    }

    for (int i = 0; i < shapelets.size(); i++) {
      if (selfSimilar[i] == false) {
        outputShapelets.add(shapelets.get(i));
        for (int j = i + 1; j < shapelets.size(); j++) {
          if (selfSimilar[j] == false && selfSimilarity(shapelets.get(i), shapelets.get(j))) { // no
                                                                                               // point
                                                                                               // recalc'ing
                                                                                               // if
                                                                                               // already
                                                                                               // self
                                                                                               // similar
                                                                                               // to
                                                                                               // something
            selfSimilar[j] = true;
          }
        }
      }
    }
    return outputShapelets;
  }

  /**
   * 
   * @param k the maximum number of shapelets to be returned after combining the two lists
   * @param kBestSoFar the (up to) k best shapelets that have been observed so far, passed in to
   * combine with shapelets from a new series
   * @param timeSeriesShapelets the shapelets taken from a new series that are to be merged in
   * descending order of fitness with the kBestSoFar
   * @return an ordered ArrayList of the best k (or less) Shapelet objects from the union of the
   * input ArrayLists
   */

  // NOTE: could be more efficient here
  private ArrayList<Shapelet> combine(int k, ArrayList<Shapelet> kBestSoFar,
      ArrayList<Shapelet> timeSeriesShapelets) {

    ArrayList<Shapelet> newBestSoFar = new ArrayList<Shapelet>();
    for (int i = 0; i < timeSeriesShapelets.size(); i++) {
      kBestSoFar.add(timeSeriesShapelets.get(i));
    }
    Collections.sort(kBestSoFar);
    if (kBestSoFar.size() < k)
      return kBestSoFar; // no need to return up to k, as there are not k shapelets yet

    for (int i = 0; i < k; i++) {
      newBestSoFar.add(kBestSoFar.get(i));
    }

    return newBestSoFar;
  }

  /**
   * 
   * @param data the input data set that the class distributions are to be derived from
   * @return a TreeMap<Double, Integer> in the form of <Class Value, Frequency>
   */
  private static TreeMap<Double, Integer> getClassDistributions(Instances data) {
    TreeMap<Double, Integer> classDistribution = new TreeMap<Double, Integer>();
    double classValue;
    for (int i = 0; i < data.numInstances(); i++) {
      classValue = data.instance(i).classValue();
      boolean classExists = false;
      for (Double d : classDistribution.keySet()) {
        if (d == classValue) {
          int temp = classDistribution.get(d);
          temp++;
          classDistribution.put(classValue, temp);
          classExists = true;
        }
      }
      if (classExists == false) {
        classDistribution.put(classValue, 1);
      }
    }
    return classDistribution;
  }

  /**
   * 
   * @param candidate the data from the candidate Shapelet
   * @param data the entire data set to compare the candidate to
   * @param data the entire data set to compare the candidate to
   * @return a TreeMap<Double, Integer> in the form of <Class Value, Frequency>
   */
  private static Shapelet checkCandidate(double[] candidate, Instances data, int seriesId,
      int startPos, TreeMap classDistribution) {

    // create orderline by looping through data set and calculating the subsequence
    // distance from candidate to all data, inserting in order.
    ArrayList<OrderLineObj> orderline = new ArrayList<OrderLineObj>();

    for (int i = 0; i < data.numInstances(); i++) {
      double distance = subsequenceDistance(candidate, data.instance(i));
      double classVal = data.instance(i).classValue();

      // without early abandon, it is faster to just add and sort at the end
      orderline.add(new OrderLineObj(distance, classVal));
    }
    Collections.sort(orderline, new orderLineComparator());

    // create a shapelet object to store all necessary info, i.e.
    // content, seriesId, then calc info gain, plit threshold and separation gap
    Shapelet shapelet = new Shapelet(candidate, seriesId, startPos);
    shapelet.calcInfoGainAndThreshold(orderline, classDistribution);

    // note: early abandon entropy pruning would appear here, but has been ommitted
    // in favour of a clear multi-class information gain calculation. Could be added in
    // this method in the future for speed up, but distance early abandon is more important

    return shapelet;
  }

  // for sorting the orderline
  private static class orderLineComparator implements Comparator<OrderLineObj> {
    public int compare(OrderLineObj o1, OrderLineObj o2) {
      if (o1.distance < o2.distance)
        return -1;
      else if (o1.distance > o2.distance)
        return 1;
      else
        return 0;
    }
  }

  private static double entropy(TreeMap<Double, Integer> classDistributions) {
    if (classDistributions.size() == 1) {
      return 0;
    }

    double thisPart;
    double toAdd;
    int total = 0;
    for (Double d : classDistributions.keySet()) {
      total += classDistributions.get(d);
    }
    // to avoid NaN calculations, the individual parts of the entropy are calculated and summed.
    // i.e. if there is 0 of a class, then that part would calculate as NaN, but this can be caught
    // and
    // set to 0.
    ArrayList<Double> entropyParts = new ArrayList<Double>();
    for (Double d : classDistributions.keySet()) {
      thisPart = (double) classDistributions.get(d) / total;
      toAdd = -thisPart * Math.log10(thisPart) / Math.log10(2);
      if (Double.isNaN(toAdd))
        toAdd = 0;
      entropyParts.add(toAdd);
    }

    double entropy = 0;
    for (int i = 0; i < entropyParts.size(); i++) {
      entropy += entropyParts.get(i);
    }
    return entropy;
  }

  /**
   * 
   * @param candidate
   * @param timeSeriesIns
   * @return
   */
  public static double subsequenceDistance(double[] candidate, Instance timeSeriesIns) {
    double[] timeSeries = timeSeriesIns.toDoubleArray();
    return subsequenceDistance(candidate, timeSeries);
  }

  public static double subsequenceDistance(double[] candidate, double[] timeSeries) {

    double bestSum = Double.MAX_VALUE;
    double sum = 0;
    double[] subseq;

    // for all possible subsequences of two
    for (int i = 0; i <= timeSeries.length - candidate.length - 1; i++) {
      sum = 0;
      // get subsequence of two that is the same lenght as one
      subseq = new double[candidate.length];

      for (int j = i; j < i + candidate.length; j++) {
        subseq[j - i] = timeSeries[j];
      }
      subseq = zNorm(subseq, false); // Z-NORM HERE
      for (int j = 0; j < candidate.length; j++) {
        sum += (candidate[j] - subseq[j]) * (candidate[j] - subseq[j]);
      }
      if (sum < bestSum) {
        bestSum = sum;
      }
    }
    return (1.0 / candidate.length * bestSum);
  }

  /**
   * 
   * @param input
   * @param classValOn
   * @return
   */
  public static double[] zNorm(double[] input, boolean classValOn) {
    double mean;
    double stdv;

    double classValPenalty = 0;
    if (classValOn) {
      classValPenalty = 1;
    }
    double[] output = new double[input.length];
    double seriesTotal = 0;

    for (int i = 0; i < input.length - classValPenalty; i++) {
      seriesTotal += input[i];
    }

    mean = seriesTotal / (input.length - classValPenalty);
    stdv = 0;
    for (int i = 0; i < input.length - classValPenalty; i++) {
      stdv += (input[i] - mean) * (input[i] - mean);
    }

    stdv = stdv / input.length - classValPenalty;
    stdv = Math.sqrt(stdv);

    for (int i = 0; i < input.length - classValPenalty; i++) {
      output[i] = (input[i] - mean) / stdv;
    }

    if (classValOn == true) {
      output[output.length - 1] = input[input.length - 1];
    }

    return output;
  }

  /**
   * 
   * @param fileName
   * @return
   */
  public static Instances loadData(String fileName) {
    Instances data = null;
    try {
      FileReader r;
      r = new FileReader(fileName);
      data = new Instances(r);

      data.setClassIndex(data.numAttributes() - 1);
    }
    catch (Exception e) {
      System.out.println(" Error =" + e + " in method loadData");
      e.printStackTrace();
    }
    return data;
  }

  private static boolean selfSimilarity(Shapelet shapelet, Shapelet candidate) {
    if (candidate.seriesId == shapelet.seriesId) {
      if (candidate.startPos >= shapelet.startPos
          && candidate.startPos < shapelet.startPos + shapelet.content.length) { // candidate starts
                                                                                 // within exisiting
                                                                                 // shapelet
        return true;
      }
      if (shapelet.startPos >= candidate.startPos
          && shapelet.startPos < candidate.startPos + candidate.content.length) {
        return true;
      }
    }
    return false;
  }

  private static class Shapelet implements Comparable<Shapelet> {
    private double[] content;
    private int seriesId;
    private int startPos;
    private double splitThreshold;
    private double informationGain;
    private double separationGap;

    private Shapelet(double[] content, int seriesId, int startPos) {
      this.content = content;
      this.seriesId = seriesId;
      this.startPos = startPos;
    }

    // TEMPORARY - for testing
    private Shapelet(double[] content, int seriesId, int startPos, double splitThreshold,
        double gain, double gap) {
      this.content = content;
      this.seriesId = seriesId;
      this.startPos = startPos;
      this.splitThreshold = splitThreshold;
      this.informationGain = gain;
      this.separationGap = gap;
    }

    // TEMP - used when processing has been carried out in initial stage, then the shapelets read in
    // via csv later
    private Shapelet(double[] content) {
      this.content = content;
    }

    /*
     * note: we calculate the threshold as this is used for finding the best split point in the data
     * however, as this implementation of shapelets is as a filter, we do not actually use the
     * threshold in the transformation.
     */

    private void calcInfoGainAndThreshold(ArrayList<OrderLineObj> orderline,
        TreeMap<Double, Integer> classDistribution) {
      // for each split point, starting between 0 and 1, ending between end-1 and end
      // addition: track the last threshold that was used, don't bother if it's the same as the last
      // one
      double lastDist = orderline.get(0).distance; // must be initialised as not visited(no point
                                                   // breaking before any data!)
      double thisDist = -1;

      double bsfGain = -1;
      double threshold = -1;

      // check that there is actually a split point
      // for example, if all

      for (int i = 1; i < orderline.size(); i++) {
        thisDist = orderline.get(i).distance;
        if (i == 1 || thisDist != lastDist) { // check that threshold has moved(no point in sampling
                                              // identical thresholds)- special case - if 0 and 1
                                              // are the same dist

          // count class instances below and above threshold
          TreeMap<Double, Integer> lessClasses = new TreeMap<Double, Integer>();
          TreeMap<Double, Integer> greaterClasses = new TreeMap<Double, Integer>();

          for (double j : classDistribution.keySet()) {
            lessClasses.put(j, 0);
            greaterClasses.put(j, 0);
          }

          int sumOfLessClasses = 0;
          int sumOfGreaterClasses = 0;

          // visit those below threshold
          for (int j = 0; j < i; j++) {
            double thisClassVal = orderline.get(j).classVal;
            int storedTotal = lessClasses.get(thisClassVal);
            storedTotal++;
            lessClasses.put(thisClassVal, storedTotal);
            sumOfLessClasses++;
          }

          // visit those above threshold
          for (int j = i; j < orderline.size(); j++) {
            double thisClassVal = orderline.get(j).classVal;
            int storedTotal = greaterClasses.get(thisClassVal);
            storedTotal++;
            greaterClasses.put(thisClassVal, storedTotal);
            sumOfGreaterClasses++;
          }

          int sumOfAllClasses = sumOfLessClasses + sumOfGreaterClasses;

          double parentEntropy = entropy(classDistribution);

          // calculate the info gain below the threshold
          double lessFrac = (double) sumOfLessClasses / sumOfAllClasses;
          double entropyLess = entropy(lessClasses);
          // calculate the info gain above the threshold
          double greaterFrac = (double) sumOfGreaterClasses / sumOfAllClasses;
          double entropyGreater = entropy(greaterClasses);

          double gain = parentEntropy - lessFrac * entropyLess - greaterFrac * entropyGreater;
          if (gain > bsfGain) {
            bsfGain = gain;
            threshold = (thisDist - lastDist) / 2 + lastDist;
          }
        }
        lastDist = thisDist;
      }
      if (bsfGain >= 0) {
        this.informationGain = bsfGain;
        this.splitThreshold = threshold;
        this.separationGap = calculateSeparationGap(orderline, threshold);
      }
    }

    private double calculateSeparationGap(ArrayList<OrderLineObj> orderline,
        double distanceThreshold) {

      double sumLeft = 0;
      double leftSize = 0;
      double sumRight = 0;
      double rightSize = 0;

      for (int i = 0; i < orderline.size(); i++) {
        if (orderline.get(i).distance < distanceThreshold) {
          sumLeft += orderline.get(i).distance;
          leftSize++;
        }
        else {
          sumRight += orderline.get(i).distance;
          rightSize++;
        }
      }

      double thisSeparationGap = 1 / rightSize * sumRight - 1 / leftSize * sumLeft;

      if (rightSize == 0 || leftSize == 0) {
        return -1; // obviously there was no seperation, which is likely to be very rare but i still
                   // caused it!
      } // e.g if all data starts with 0, first shapelet length =1, there will be no seperation as
        // all time series are same dist
      // equally true if all data contains the shapelet candidate, which is a more realistic example

      return thisSeparationGap;
    }

    // comparison 1: to determine order of shapelets in terms of info gain, then separation gap,
    // then shortness
    public int compareTo(Shapelet shapelet) {
      final int BEFORE = -1;
      final int EQUAL = 0;
      final int AFTER = 1;

      if (this.informationGain != shapelet.informationGain) {
        if (this.informationGain > shapelet.informationGain) {
          return BEFORE;
        }
        else {
          return AFTER;
        }
      }
      else {
        if (this.separationGap != shapelet.separationGap) {
          if (this.separationGap > shapelet.separationGap) {
            return BEFORE;
          }
          else {
            return AFTER;
          }
        }
        else if (this.content.length != shapelet.content.length) {
          if (this.content.length < shapelet.content.length) {
            return BEFORE;
          }
          else {
            return AFTER;
          }
        }
        else {
          return EQUAL;
        }
      }

    }
  }

  private static class OrderLineObj {

    private double distance;
    private double classVal;

    private OrderLineObj(double distance, double classVal) {
      this.distance = distance;
      this.classVal = classVal;
    }
  }

  // /**
  // *
  // * @param args
  // * @throws Exception
  // */
  // public static void main(String[] args) throws Exception{
  // ShapeletFilter sf = new ShapeletFilter(10, 5, 5);
  // Instances data = loadData("example.arff");
  //
  // sf.process(data);
  // }

  public static ShapeletFilter createFilterFromFile(String fileName) throws Exception {

    File input = new File(fileName);
    Scanner scan = new Scanner(input);
    scan.useDelimiter("\n");

    ShapeletFilter sf = new ShapeletFilter();
    ArrayList<Shapelet> shapelets = new ArrayList<Shapelet>();

    String shapeletContentString;
    ArrayList<Double> content;
    double[] contentArray;
    Scanner lineScan;

    while (scan.hasNext()) {
      scan.next();
      shapeletContentString = scan.next();

      lineScan = new Scanner(shapeletContentString);
      lineScan.useDelimiter(",");

      content = new ArrayList<Double>();
      while (lineScan.hasNext()) {
        content.add(Double.parseDouble(lineScan.next().trim()));
      }

      contentArray = new double[content.size()];
      for (int i = 0; i < content.size(); i++) {
        contentArray[i] = content.get(i);
      }

      Shapelet s = new Shapelet(contentArray);
      shapelets.add(s);
    }

    sf.shapelets = shapelets;
    sf.shapeletsTrained = true;
    sf.numShapelets = shapelets.size();
    sf.setShapeletMinAndMax(1, 1);

    return sf;
  }

}
