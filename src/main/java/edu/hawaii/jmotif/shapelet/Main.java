package edu.hawaii.jmotif.shapelet;

import weka.core.Instances;

public class Main {
  // example use of the filter
  public static void main(String[] args) {
    try {
      // mandatory requirements: numShapelets (k), min shapelet length, max shapelet length, input
      // data
      // additional information: log output dir

      // example filter, k = 10, minLength = 20, maxLength = 40, data = , output = exampleOutput.txt
      int k = 10;
      int minLength = 10;
      int maxLength = 20;
      Instances data = ShapeletFilter.loadData(args[0]);

      ShapeletFilter sf = new ShapeletFilter(k, minLength, maxLength);
      sf.setLogOutputFile("exampleOutput.txt"); // log file stores shapelet output

      // Note: sf.process returns a transformed set of Instances. The first time that
      // thisFilter.process(data) is called, shapelet extraction occurs. Subsequent calls to process
      // uses the previously extracted shapelets to transform the data. For example:
      //
      // Instances transformedTrain = sf.process(trainingData); -> extracts shapelets and can be
      // used to transform training data
      // Instances transformedTest = sf.process(testData); -> uses shapelets extracted from
      // trainingData to transform testData
      Instances transformed = sf.process(data);
    }
    catch (Exception e) {
      e.printStackTrace();
    }

  }

}
