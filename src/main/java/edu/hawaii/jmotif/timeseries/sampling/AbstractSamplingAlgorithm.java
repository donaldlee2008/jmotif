package edu.hawaii.jmotif.timeseries.sampling;

import edu.hawaii.jmotif.timeseries.Timeseries;

/**
 * An abstraction of sampling algorithm.
 * 
 * @author psenin
 * 
 */
public abstract class AbstractSamplingAlgorithm {

  /**
   * Performs re-sampling of irregular series into the regular one.
   * 
   * @param ts The input timeseries.
   * 
   * @return Re-sampled series.
   */
  public abstract Timeseries resample(Timeseries ts);

}
