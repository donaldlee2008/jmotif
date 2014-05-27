package edu.hawaii.jmotif.sax;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import org.junit.Before;
import org.junit.Test;
import edu.hawaii.jmotif.sax.SAXFactory;
import edu.hawaii.jmotif.sax.alphabet.Alphabet;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;
import edu.hawaii.jmotif.timeseries.Timeseries;

/**
 * Code used for the discords web example.
 * 
 * @author psenin
 * 
 */
public class TestSAXWeb {

  /** Some constants go here. */
  private static final double[] seriesAValues = { 0.22, 0.23, 0.24, 0.50, 0.83 };
  private static final long[] seriesATstamps = { 22L, 23L, 24L, 50L, 83L };

  private static final Alphabet normalA = new NormalAlphabet();

  /** Series under the test. */
  private Timeseries seriesA;

  /**
   * The test setup.
   * 
   * @throws Exception if error occurs.
   */
  @Before
  public void setUp() throws Exception {
    seriesA = new Timeseries(seriesAValues, seriesATstamps);
  }

  /**
   * Test that the timeseries was created.
   */
  @Test
  public void testSeriesSetup() {
    assertNotNull("Is it null?", seriesA);
  }

  /**
   * Test normalization.
   * 
   * @throws TSException if error occurs.
   * @throws CloneNotSupportedException
   */
  @Test
  public void testNormalization() throws TSException, CloneNotSupportedException {
    Timeseries myNormalizedData = TSUtils.zNormalize(seriesA);
    // *****
    // The test code in R
    // data <- c(0.22, 0.23, 0.24, 0.50, 0.83)
    // data.mean <- mean(data)
    // data.sd <- sqrt(var(data))
    // data.norm <- (data - data.mean) / data.sd
    // data.norm
    // [1] -0.6933284 -0.6556475 -0.6179666 0.3617365 1.6052059
    assertEquals(myNormalizedData.elementAt(0).value(), -0.6933284, 0.0000001);
    assertEquals(myNormalizedData.elementAt(1).value(), -0.6556475, 0.0000001);
    assertEquals(myNormalizedData.elementAt(2).value(), -0.6179666, 0.0000001);
    assertEquals(myNormalizedData.elementAt(3).value(), 0.3617365, 0.0000001);
    assertEquals(myNormalizedData.elementAt(4).value(), 1.6052059, 0.0000001);
  }

  /**
   * Test the PAA approximation.
   * 
   * @throws TSException if Error occurs.
   * @throws CloneNotSupportedException if Error occurs.
   */
  @Test
  public void testPAA() throws TSException, CloneNotSupportedException {
    // data.norm <- znorm(t(as.matrix(data)))
    // data.paa3 <- paa(data.norm, 3)
    // data.paa3
    // [1,] -0.678256 -0.4295621 1.107818
    Timeseries myPAAapproximatedData = TSUtils.paa(TSUtils.zNormalize(seriesA), 3);
    assertEquals(myPAAapproximatedData.elementAt(0).value(), -0.678256, 0.0000001);
    assertEquals(myPAAapproximatedData.elementAt(1).value(), -0.4295621, 0.0000001);
    assertEquals(myPAAapproximatedData.elementAt(2).value(), 1.107818, 0.000001);
  }

  /**
   * Test the PAA approximation.
   * 
   * @throws TSException if Error occurs.
   * @throws CloneNotSupportedException if Error occurs.
   */
  @Test
  public void testSAX() throws TSException, CloneNotSupportedException {
    // data.norm <- znorm(t(as.matrix(data)))
    // data.paa3 <- paa(data.norm, 3)
    // data.sax3 <- ts2string(data.paa3, 3)
    // data.sax3
    // [1] "a" "b" "c"
    String timeseriesAsax3 = SAXFactory.ts2string(seriesA, 3, normalA, 3);
    assertEquals("Testing timeseries", timeseriesAsax3.charAt(0), 'a');
    assertEquals("Testing timeseries", timeseriesAsax3.charAt(1), 'b');
    assertEquals("Testing timeseries", timeseriesAsax3.charAt(2), 'c');
    System.out.println(timeseriesAsax3);
  }

}
