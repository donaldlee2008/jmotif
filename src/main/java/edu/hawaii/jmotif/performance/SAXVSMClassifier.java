package edu.hawaii.jmotif.performance;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import weka.classifiers.Classifier;
import weka.core.Attribute;
import weka.core.Capabilities;
import weka.core.Capabilities.Capability;
import weka.core.Instance;
import weka.core.Instances;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;

public class SAXVSMClassifier extends weka.classifiers.AbstractClassifier implements Classifier {

  /**
   * 
   */
  private static final long serialVersionUID = 1L;
  private int window;
  private int paa;
  private int alphabet;
  private SAXCollectionStrategy strategy;

  private Instances m_Instances;
  private HashMap<String, HashMap<String, Double>> tfidf;

  @Override
  public void buildClassifier(Instances instances) throws Exception {
    // can classifier handle the data?
    getCapabilities().testWithFail(instances);

    // remove instances with missing class
    instances = new Instances(instances);
    instances.deleteWithMissingClass();

    // Copy the instances
    m_Instances = new Instances(instances);

    // build Vectors Map<String, List<double[]>> data
    Map<String, List<double[]>> trainData = new HashMap<String, List<double[]>>();
    for (Instance i : m_Instances) {
      String classAttribute = i.classAttribute().value(Double.valueOf(i.classValue()).intValue());
      double[] series = new double[i.numAttributes()];
      for (int k = 0; k < i.numAttributes(); k++) {
        series[k] = i.value(k);
      }
      if (trainData.containsKey(classAttribute)) {
        trainData.get(classAttribute).add(series);
      }
      else {
        trainData.put(classAttribute, new ArrayList<double[]>());
        trainData.get(classAttribute).add(series);
      }
      // System.out.println(classAttribute);
    }

    // making training bags collection
    List<WordBag> bags = TextUtils.labeledSeries2WordBags(trainData, this.paa, this.alphabet,
        this.window, this.strategy);

    // getting TFIDF done
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags);

    // System.out.println(TextUtils.bagsToTable(bags));

    // normalize vectors
    this.tfidf = TextUtils.normalizeToUnitVectors(tfidf);

  }

  @Override
  public double classifyInstance(Instance instance) throws Exception {
    double[] series = new double[instance.numAttributes()];
    for (int k = 0; k < instance.numAttributes(); k++) {
      series[k] = instance.value(k);
    }
    int[] params = { this.window, this.paa, this.alphabet, this.strategy.index() };
    String value = TextUtils
        .classify(TextUtils.seriesToWordBag("test", series, params), this.tfidf);
    return m_Instances.classAttribute().indexOfValue(value);
  }

  @Override
  public double[] distributionForInstance(Instance instance) throws Exception {
    double[] series = new double[instance.numAttributes()];
    for (int k = 0; k < instance.numAttributes(); k++) {
      series[k] = instance.value(k);
    }
    int[] params = { this.window, this.paa, this.alphabet, this.strategy.index() };
    WordBag bag = TextUtils.seriesToWordBag("test", series, params);

    double[] res = new double[m_Instances.numClasses()];
    for (int i = 0; i < m_Instances.numClasses(); i++) {
      String aClass = m_Instances.classAttribute().value(i);
      double sim = TextUtils.cosineSimilarity(bag, tfidf.get(aClass));
      res[i] = sim;
    }

    return res;

  }

  @Override
  public Capabilities getCapabilities() {

    Capabilities result = super.getCapabilities(); // returns the object from
                                                   // weka.classifiers.Classifier
    // attributes
    result.enable(Capability.NUMERIC_ATTRIBUTES);

    // class
    result.enable(Capability.NOMINAL_CLASS);

    return result;
  }

  public void setSAXParams(int i, int j, int k, String string) {
    this.window = i;
    this.paa = j;
    this.alphabet = k;
    // configuring strategy
    //
    this.strategy = SAXCollectionStrategy.NOREDUCTION;
    if ("EXACT".equalsIgnoreCase(string)) {
      strategy = SAXCollectionStrategy.EXACT;
    }
    if ("CLASSIC".equalsIgnoreCase(string)) {
      strategy = SAXCollectionStrategy.CLASSIC;
    }
  }

}
