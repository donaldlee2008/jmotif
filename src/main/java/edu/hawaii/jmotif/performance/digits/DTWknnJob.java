package edu.hawaii.jmotif.performance.digits;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.Callable;
import com.dtw.TimeWarpInfo;
import com.timeseries.TimeSeries;
import com.timeseries.TimeSeriesPoint;
import com.util.DistanceFunction;
import com.util.DistanceFunctionFactory;
import edu.hawaii.jmotif.performance.KNNStackEntry;

public class DTWknnJob implements Callable<String> {

  private double[] series;
  private int seriesCounter;
  private Map<String, double[]> trainData;

  public DTWknnJob(double[] series, int seriesCounter, Map<String, double[]> trainData) {
    this.series = series;
    this.seriesCounter = seriesCounter;
    this.trainData = trainData;
  }

  @Override
  public String call() throws Exception {
    return getVotes(getNeighbors(series, trainData));
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
      votes[Integer.valueOf(s.substring(0,s.indexOf("_")))]++;
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

  private ArrayList<KNNStackEntry<String, Double>> getNeighbors(double[] series,
      Map<String, double[]> trainData) {
    ArrayList<KNNStackEntry<String, Double>> res = new ArrayList<KNNStackEntry<String, Double>>();
    for (Entry<String, double[]> e : trainData.entrySet()) {
      double dist = getDist(series, e.getValue());
      if (res.size() < 10) {
        res.add(new KNNStackEntry<String, Double>(e.getKey(), dist));
      }
      else {
        checkDist(res, e.getKey(), dist);
      }
    }
    return res;
  }

  private void checkDist(ArrayList<KNNStackEntry<String, Double>> res, String label, double dist) {
    Collections.sort(res, new Comparator<KNNStackEntry<String, Double>>() {
      @Override
      public int compare(KNNStackEntry<String, Double> arg0, KNNStackEntry<String, Double> arg1) {
        return arg0.getValue().compareTo(arg1.getValue());
      }
    });

    if (res.get(9).getValue() > dist) {
      res.remove(9);
      res.add(new KNNStackEntry<String, Double>(label, dist));
    }

  }

  private double getDist(double[] series1, double[] series2) {

    // final TimeSeries tsI = new TimeSeries(args[0], false, false, ',');
    final TimeSeries tsI = new TimeSeries(1);
    for (int i = 0; i < series1.length; i++) {
      tsI.addLast(i, new TimeSeriesPoint(new double[] { series1[i] }));
    }

    // final TimeSeries tsJ = new TimeSeries(args[1], false, false, ',');
    final TimeSeries tsJ = new TimeSeries(1);
    for (int i = 0; i < series2.length; i++) {
      tsJ.addLast(i, new TimeSeriesPoint(new double[] { series2[i] }));
    }

    DistanceFunction distFn = DistanceFunctionFactory.getDistFnByName("EuclideanDistance");

    final TimeWarpInfo info = com.dtw.FastDTW.getWarpInfoBetween(tsI, tsJ, 10, distFn);

    return info.getDistance();
  }
}
