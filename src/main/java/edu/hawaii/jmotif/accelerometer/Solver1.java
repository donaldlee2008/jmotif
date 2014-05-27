package edu.hawaii.jmotif.accelerometer;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map.Entry;
import org.joda.time.LocalTime;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.timeseries.TSException;

public class Solver1 {

  protected final static int CLASSIC = 0;
  protected final static int EXACT = 1;
  protected final static int NOREDUCTION = 2;

  private final static int[] params = { 60, 20, 3, NOREDUCTION };

  private static final File TRAIN_FOLDER = new File("data/accelerometer/train_series");

  private static final File TEST_FOLDER = new File("data/accelerometer/test_series");

  private static final File QUESTIONS_FNAME = new File("data/accelerometer/questions.csv");

  /**
   * @param args
   * @throws TSException
   * @throws IOException
   * @throws IndexOutOfBoundsException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, IOException, TSException {

    // read series
    //
    HashMap<String, ArrayList<APoint>> train = readTrainData();

    // convert into bags
    //
    int ctr = 1;
    HashMap<String, HashMap<String, WordBag>> trainBags = new HashMap<String, HashMap<String, WordBag>>();
    for (Entry<String, ArrayList<APoint>> e : train.entrySet()) {

      System.out.println("processing device " + e.getKey() + " " + ctr + " out of " + train.size());

      HashMap<String, WordBag> seriesBags = getSeriesBags(e.getValue());

      trainBags.put(e.getKey(), seriesBags);
      
      ctr++;

    }
    train = null;

    // make tfidf
    //
    List<WordBag> Xbags = new ArrayList<WordBag>();
    List<WordBag> Ybags = new ArrayList<WordBag>();
    List<WordBag> Zbags = new ArrayList<WordBag>();
    List<WordBag> Sbags = new ArrayList<WordBag>();

    ctr = 1;
    for (Entry<String, HashMap<String, WordBag>> e : trainBags.entrySet()) {
      
      System.out.println("processing device " + e.getKey() + " " + ctr + " out of " + trainBags.size());
      
      e.getValue().get("X").setLabel(e.getKey());
      Xbags.add(e.getValue().get("X"));

      e.getValue().get("Y").setLabel(e.getKey());
      Ybags.add(e.getValue().get("Y"));

      e.getValue().get("Z").setLabel(e.getKey());
      Zbags.add(e.getValue().get("Z"));

      e.getValue().get("S").setLabel(e.getKey());
      Sbags.add(e.getValue().get("S"));
      
      ctr++;
    }

    trainBags = null;

    System.out.println("Building tfidf X...");
    HashMap<String, HashMap<String, Double>> tfidfX = TextUtils.computeTFIDF(Xbags);
    System.out.println("Building tfidf Y...");
    HashMap<String, HashMap<String, Double>> tfidfY = TextUtils.computeTFIDF(Ybags);
    System.out.println("Building tfidf Z...");
    HashMap<String, HashMap<String, Double>> tfidfZ = TextUtils.computeTFIDF(Zbags);
    System.out.println("Building tfidf S...");
    HashMap<String, HashMap<String, Double>> tfidfS = TextUtils.computeTFIDF(Sbags);
    
    Xbags = null;
    Ybags = null;
    Zbags = null;
    Sbags = null;

    // read all the questions
    List<String> questions = readQuestions(QUESTIONS_FNAME);

    for (String question : questions) {

      String[] split = question.split(",");

      String questionId = split[0];
      String proposedDeviceId = split[2];

      // read the question sequence in
      final String questionFilePrefix = split[1];
      File[] listOfQuestionFiles = TEST_FOLDER.listFiles(new FilenameFilter() {
        public boolean accept(File dir, String name) {
          return name.matches(questionFilePrefix + ".*\\.csv");
        }
      });
      File f = listOfQuestionFiles[0];
      HashMap<String, double[]> questionSeries = readSeries(listOfQuestionFiles[0]);
      HashMap<String, WordBag> bags = toBags(questionSeries, params);

      String cX = TextUtils.classify(bags.get("X"), tfidfX);
      String cY = TextUtils.classify(bags.get("Y"), tfidfY);
      String cZ = TextUtils.classify(bags.get("Z"), tfidfZ);
      String cS = TextUtils.classify(bags.get("S"), tfidfS);

      System.out.println(questionId + " " + proposedDeviceId + " " + cX + " " + cY + " " + cZ + " "
          + cS + " ");

    }

  }

  private static HashMap<String, ArrayList<APoint>> readTrainData() throws IOException {

    BufferedReader br = new BufferedReader(new FileReader(new File(
        "data/accelerometer/train.csv")));

    HashMap<String, ArrayList<APoint>> series = new HashMap<String, ArrayList<APoint>>();

    String line = "";
    int counter = 0;
    String header = br.readLine();

    while ((line = br.readLine()) != null) {

      String[] split = line.split(",");

      String deviceId = split[4];

      if (!(series.containsKey(deviceId))) {

        series.put(deviceId, new ArrayList<APoint>());

      }

      series.get(deviceId).add(new APoint(line));

      if (counter % 1000000 == 0) {
        System.out.println("read " + counter + " lines");
      }
      counter++;
    }

    br.close();

    return series;

  }

  private static List<String> readQuestions(File fname) throws IOException {
    List<String> res = new ArrayList<String>();

    BufferedReader br = new BufferedReader(new FileReader(fname));
    br.readLine();

    String line = "";

    while ((line = br.readLine()) != null) {
      res.add(line);
    }
    br.close();

    return res;
  }

  private static HashMap<String, WordBag> toBags(HashMap<String, double[]> series, int[] params)
      throws IndexOutOfBoundsException, TSException {

    HashMap<String, WordBag> seriesBags = new HashMap<String, WordBag>();
    seriesBags.put("X", TextUtils.seriesToWordBag("X", series.get("X"), params));
    seriesBags.put("Y", TextUtils.seriesToWordBag("Y", series.get("Y"), params));
    seriesBags.put("Z", TextUtils.seriesToWordBag("Z", series.get("Z"), params));
    seriesBags.put("S", TextUtils.seriesToWordBag("S", series.get("S"), params));

    return seriesBags;
  }

  private static HashMap<String, double[]> readSeries(File f) throws IOException {

    ArrayList<Double> x = new ArrayList<Double>();
    ArrayList<Double> y = new ArrayList<Double>();
    ArrayList<Double> z = new ArrayList<Double>();
    ArrayList<Double> sum = new ArrayList<Double>();

    BufferedReader br = new BufferedReader(new FileReader(f));

    String line = "";

    while ((line = br.readLine()) != null) {

      String[] split = line.split(",");

      x.add(Double.valueOf(split[1]));
      y.add(Double.valueOf(split[2]));
      z.add(Double.valueOf(split[3]));
      sum.add(Double.valueOf(split[4]));

    }

    HashMap<String, double[]> res = new HashMap<String, double[]>();
    res.put("X", toDoubles(x));
    res.put("Y", toDoubles(y));
    res.put("Z", toDoubles(z));
    res.put("S", toDoubles(sum));

    return res;

  }

  private static HashMap<String, WordBag> getSeriesBags(ArrayList<APoint> value)
      throws IndexOutOfBoundsException, TSException {

    HashMap<String, WordBag> res = new HashMap<String, WordBag>();

    ArrayList<Double> x = new ArrayList<Double>();
    ArrayList<Double> y = new ArrayList<Double>();
    ArrayList<Double> z = new ArrayList<Double>();
    ArrayList<Double> sum = new ArrayList<Double>();

    APoint oldP = null;
    for (APoint p : value) {
      x.add(p.getX());
      y.add(p.getY());
      z.add(p.getZ());
      if (null != oldP) {
        sum.add(oldP.distanceTo(p));
      }
      oldP = p;
    }

    res.put("X", TextUtils.seriesToWordBag("X", toDoubles(x), params));
    res.put("Y", TextUtils.seriesToWordBag("Y", toDoubles(y), params));
    res.put("Z", TextUtils.seriesToWordBag("Z", toDoubles(z), params));
    res.put("S", TextUtils.seriesToWordBag("S", toDoubles(sum), params));
    return res;
  }

  private static double[] toDoubles(ArrayList<Double> x) {
    double[] res = new double[x.size()];
    for (int i = 0; i < x.size(); i++) {
      res[i] = x.get(i);
    }
    return res;
  }
}
