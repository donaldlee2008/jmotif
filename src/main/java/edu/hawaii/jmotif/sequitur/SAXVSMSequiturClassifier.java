package edu.hawaii.jmotif.sequitur;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import edu.hawaii.jmotif.distance.EuclideanDistance;
import edu.hawaii.jmotif.performance.UCRUtils;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;

/**
 * Helper-runner for CBF test.
 * 
 * @author psenin
 * 
 */
public class SAXVSMSequiturClassifier {

  // various variables

  // classifier test parameters
  //
  /** The timeseries length. */
  private static final int SERIES_LENGTH = 128;

  /**
   * @param args
   * @throws TSException
   * @throws IndexOutOfBoundsException
   * @throws IOException
   */
  public static void main(String[] args) throws IndexOutOfBoundsException, TSException, IOException {

    if (6 != args.length) {
      System.out.println("Expecting parameters W P A Strategy TRAIN_FILE TEST_FILE");
    }

    Integer windowSize = Integer.valueOf(args[0]);
    Integer paaSize = Integer.valueOf(args[1]);
    Integer alphabetSize = Integer.valueOf(args[2]);

    SAXCollectionStrategy strategy = SAXCollectionStrategy.NOREDUCTION;

    if ("exact".equalsIgnoreCase(args[3])) {
      strategy = SAXCollectionStrategy.EXACT;
    }
    else if ("classic".equalsIgnoreCase(args[3])) {
      strategy = SAXCollectionStrategy.CLASSIC;
    }

    // making training and test collections
    Map<String, List<double[]>> trainSet = UCRUtils.readUCRData(args[4]);
    Map<String, List<double[]>> testSet = UCRUtils.readUCRData(args[5]);

    if (windowSize < paaSize + 1) {
      System.exit(0);
    }
    // Euclidean section
    //
    //
    int classifiedSeriesNum = 0;
    int positiveEuclideanTests = 0;
    long euclidenStart = System.currentTimeMillis();

    for (String label : testSet.keySet()) {

      List<double[]> testD = testSet.get(label);

      for (double[] series : testD) {

        double bestDistance = Double.MAX_VALUE;
        String bestClass = "";
        for (Entry<String, List<double[]>> refClass : trainSet.entrySet()) {
          for (double[] refSeries : refClass.getValue()) {
            Double distance = EuclideanDistance.earlyAbandonedDistance(TSUtils.zNormalize(series),
                TSUtils.zNormalize(refSeries), bestDistance);
            if (null != distance && distance.doubleValue() < bestDistance) {
              bestDistance = distance.doubleValue();
              bestClass = refClass.getKey();
            }
          }
        }

        if (label.equalsIgnoreCase(bestClass)) {
          positiveEuclideanTests = positiveEuclideanTests + 1;
        }
        classifiedSeriesNum++;
      }

    }
    double accuracyE = (double) positiveEuclideanTests / (double) classifiedSeriesNum;
    double errorE = 1.0d - accuracyE;
    long euclideanEnd = System.currentTimeMillis();

    // TF-IDF statistics section
    //
    //
    long tfidfStart = System.currentTimeMillis();
    List<WordBag> basSaxVsm = TextUtils.labeledSeries2WordBags(trainSet, paaSize, alphabetSize,
        windowSize, strategy);
    HashMap<String, HashMap<String, Double>> tfidfSaxVsm = TextUtils.computeTFIDF(basSaxVsm);
    tfidfSaxVsm = TextUtils.normalizeToUnitVectors(tfidfSaxVsm);
    long tfidfEndSaxVsm = System.currentTimeMillis();

    List<WordBag> bagsSequitur = SequiturFactory.labeledSeries2WordBags(trainSet, paaSize, alphabetSize,
        windowSize, strategy);
    HashMap<String, HashMap<String, Double>> tfidfSequitur = TextUtils.computeTFIDF(bagsSequitur);
    tfidfSequitur = TextUtils.normalizeToUnitVectors(tfidfSequitur);
    long tfidfEndSequitur = System.currentTimeMillis();

    System.out.println(TextUtils.tfidfToTable(tfidfSaxVsm));
    System.out.println(TextUtils.tfidfToTable(tfidfSequitur));

    // SAX-VSM section
    //
    //
    classifiedSeriesNum = 0;
    int positiveSaxVsmTests = 0;

    for (String label : tfidfSaxVsm.keySet()) {
      List<double[]> testD = testSet.get(label);
      int positives = 0;
      for (double[] series : testD) {
        positives = positives
            + TextUtils.classify(label, series, tfidfSaxVsm, paaSize, alphabetSize, windowSize, strategy);
        classifiedSeriesNum++;
      }
      positiveSaxVsmTests = positiveSaxVsmTests + positives;
    }
    double accuracySaxVsm = (double) positiveSaxVsmTests / (double) classifiedSeriesNum;
    double errorSaxVsm = 1.0d - accuracySaxVsm;
    long saxVsmEnd = System.currentTimeMillis();

    // SAX-VSM-Sequitur section
    //
    //
    classifiedSeriesNum = 0;
    int positiveTestsSequitur = 0;

    for (String label : tfidfSaxVsm.keySet()) {
      List<double[]> testD = testSet.get(label);
      int positivesS = 0;
      for (double[] series : testD) {
        positivesS = positivesS
            + SequiturFactory.classify(label, series, tfidfSequitur, paaSize, alphabetSize, windowSize,
                strategy);
        classifiedSeriesNum++;
      }
      positiveTestsSequitur = positiveTestsSequitur + positivesS;
    }
    double accuracySequitur = (double) positiveTestsSequitur / (double) classifiedSeriesNum;
    double errorSequitur = 1.0d - accuracySequitur;
    long sequiturEnd = System.currentTimeMillis();

    // Output
    //
    //
    StringBuffer sb = new StringBuffer();
    sb.append("cmprun ");
    sb.append(trainSet.size() + ", ").append(testSet.size() + ", ");
    sb.append(windowSize + ", ").append(paaSize + ", ").append(alphabetSize + ", ");

    sb.append(errorE + ", ").append(errorSaxVsm + ", ").append(errorSequitur + ", ");

    sb.append(String.valueOf(euclideanEnd - euclidenStart) + ", ");
    sb.append(String.valueOf(tfidfEndSaxVsm - tfidfStart) + ", ");
    sb.append(String.valueOf(tfidfEndSequitur - tfidfEndSaxVsm) + ", ");
    sb.append(String.valueOf(saxVsmEnd - tfidfEndSequitur) + ", ");
    sb.append(String.valueOf(sequiturEnd - saxVsmEnd));

    System.out.println(sb.toString());
  }

}
