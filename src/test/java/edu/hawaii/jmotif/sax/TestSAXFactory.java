package edu.hawaii.jmotif.sax;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertTrue;
import java.util.Iterator;
import org.junit.Test;
import edu.hawaii.jmotif.sax.alphabet.Alphabet;
import edu.hawaii.jmotif.sax.alphabet.NormalAlphabet;
import edu.hawaii.jmotif.sax.datastructures.SAXFrequencyData;
import edu.hawaii.jmotif.sax.datastructures.SAXFrequencyEntry;
import edu.hawaii.jmotif.timeseries.TSException;
import edu.hawaii.jmotif.timeseries.TSUtils;
import edu.hawaii.jmotif.timeseries.Timeseries;
import org.junit.Ignore;

/**
 * Test SAX factory methods.
 *
 * @author Pavel Senin
 *
 */
public class TestSAXFactory {

  private static final String ts1File = "RCode/data/timeseries01.csv";
  private static final String ts2File = "RCode/data/timeseries02.csv";

  private static final String ts1StrRep10 = "bcjkiheebb";
  private static final String ts2StrRep10 = "bcefgijkdb";

  private static final String ts1StrRep14 = "bcdijjhgfeecbb";
  private static final String ts2StrRep14 = "bbdeeffhijjfbb";

  private static final String ts1StrRep7 = "bcggfddba";
  private static final String ts2StrRep7 = "accdefgda";

  private static final int length = 15;
  private static final int strLength = 10;

  private static final Alphabet normalA = new NormalAlphabet();

  private static final double delta = 0.000001;

  /**
   * Test the SAX conversion.
   *
   * @throws Exception if error occurs.
   */
  @Ignore
  @Test
  public void testTs2string() throws Exception {
    Timeseries ts1 = TSUtils.readTS(ts1File, length);
    Timeseries ts2 = TSUtils.readTS(ts2File, length);

    // series #1 based test
    String ts1sax = SAXFactory.ts2string(ts1, 10, normalA, 11);
    assertEquals("testing SAX", strLength, ts1sax.length());
    assertTrue("testing SAX", ts1StrRep10.equalsIgnoreCase(ts1sax));

    ts1sax = SAXFactory.ts2string(ts1, 14, normalA, 10);
    assertEquals("testing SAX", 14, ts1sax.length());
    assertTrue("testing SAX", ts1StrRep14.equalsIgnoreCase(ts1sax));

    ts1sax = SAXFactory.ts2string(ts1, 9, normalA, 7);
    assertEquals("testing SAX", 9, ts1sax.length());
    assertTrue("testing SAX", ts1StrRep7.equalsIgnoreCase(ts1sax));

    // series #2 goes here
    String ts2sax = SAXFactory.ts2string(ts2, 10, normalA, 11);
    assertEquals("testing SAX", strLength, ts2sax.length());
    assertTrue("testing SAX", ts2StrRep10.equalsIgnoreCase(ts2sax));

    ts2sax = SAXFactory.ts2string(ts2, 14, normalA, 10);
    assertEquals("testing SAX", 14, ts2sax.length());
    assertTrue("testing SAX", ts2StrRep14.equalsIgnoreCase(ts2sax));

    ts2sax = SAXFactory.ts2string(ts2, 9, normalA, 7);
    assertEquals("testing SAX", 9, ts2sax.length());
    assertTrue("testing SAX", ts2StrRep7.equalsIgnoreCase(ts2sax));
  }

  /**
   * Test the distance function.
   *
   * @throws Exception if error occur.
   */
  @Ignore
  @Test
  public void testTs2sax() throws Exception {
    Timeseries ts1 = TSUtils.readTS(ts1File, length);
    Timeseries ts2 = TSUtils.readTS(ts2File, length);

    String ts2str_0 = SAXFactory.ts2string(ts2.subsection(0, 4), 5, normalA, 10);
    String ts2str_3 = SAXFactory.ts2string(ts2.subsection(3, 7), 5, normalA, 10);
    String ts2str_7 = SAXFactory.ts2string(ts2.subsection(7, 11), 5, normalA, 10);

    SAXFrequencyData ts2SAX = SAXFactory.ts2saxZNorm(TSUtils.zNormalize(ts2), 5, 5, normalA, 10);

    assertEquals("Testing ts2saxOptimized", (Integer) (ts2.size() - 5 + 1), ts2SAX.size());

    assertTrue("Testing ts2sax", ts2SAX.contains(ts2str_0));
    assertTrue("Testing ts2sax", ts2SAX.contains(ts2str_3));
    assertTrue("Testing ts2sax", ts2SAX.contains(ts2str_7));

    assertSame("Testing ts2sax", ts2SAX.get(ts2str_0).getEntries().get(0), 0);
    assertSame("Testing ts2sax", ts2SAX.get(ts2str_3).getEntries().get(0), 3);
    assertSame("Testing ts2sax", ts2SAX.get(ts2str_7).getEntries().get(0), 7);

  }

  /**
   * Test the distance function.
   *
   * @throws TSException if error occurs.
   */
  @Ignore
  @Test
  public void testStringDistance() throws TSException {
      double testDelta = 0.010000;
    assertEquals("testing SAX distance", 0, SAXFactory.strDistance(new char[] { 'a' },
        new char[] { 'b' }));
    assertEquals("testing SAX distance", 2, SAXFactory.strDistance(new char[] { 'a', 'a', 'a' },
        new char[] { 'b', 'c', 'b' }));

    Alphabet a = new NormalAlphabet();
    assertEquals("testing SAX distance", 0.86D, SAXFactory.saxMinDist(new char[] { 'a', 'a', 'a' },
        new char[] { 'b', 'c', 'b' }, a.getDistanceMatrix(3)), testDelta);

    assertEquals("testing SAX distance", 0.0D, SAXFactory.saxMinDist(new char[] { 'a', 'a', 'a' },
        new char[] { 'b', 'b', 'b' }, a.getDistanceMatrix(3)), testDelta);
  }

  /**
   * Test the SAX conversion when NaN's presented in the timeseries.
   *
   * @throws Exception if error occurs.
   */
  @Ignore
  @Test
  public void testTs2stringWithNAN() throws Exception {

    // read the timeseries first
    Timeseries ts1 = TSUtils.readTS(ts1File, length);
    Timeseries ts2 = TSUtils.readTS(ts2File, length);

    // series #1 based test
    String ts1sax = SAXFactory.ts2string(ts1, 10, normalA, 11);
    assertEquals("testing SAX", strLength, ts1sax.length());
    assertTrue("testing SAX", ts1StrRep10.equalsIgnoreCase(ts1sax));

    Timeseries ts1WithNaN = new Timeseries(ts1.values(), ts1.tstamps(), ts1.values()[2]);
    String tsWithNaN1sax = String.valueOf(TSUtils.ts2StringWithNaNByCuts(ts1WithNaN, normalA
        .getCuts(11)));
    assertSame("Checking Z conversion", tsWithNaN1sax.charAt(2), '_');

    SAXFrequencyData tsWithNaN = SAXFactory.ts2saxNoZnormByCuts(ts1WithNaN, 14, 14, normalA
        .getCuts(11));
    SAXFrequencyEntry sfe = tsWithNaN.getSortedFrequencies().get(0);
    assertSame("Checking Z conversion", sfe.getSubstring().charAt(1), '_');
  }

  /**
   * Test the SAX conversion when NaN's presented in the timeseries.
   *
   * @throws Exception if error occurs.
   */
  @Ignore
  @Test
  public void testTs2saxZnormByCuts() throws Exception {
    //
    // get series
    Timeseries timeSeries01 = TSUtils.readTS(ts1File, length);
    Timeseries timeSeries02 = TSUtils.readTS(ts2File, length);

    //
    // convert to sax with 2 letters alphabet and internal normalization

    double[] cut = { 0.0D };
    SAXFrequencyData sax = SAXFactory.ts2saxZnormByCuts(timeSeries01, 14, 10, cut);
    Iterator<SAXFrequencyEntry> i = sax.iterator();
    SAXFrequencyEntry entry0 = i.next();
    assertTrue("Testing SAX routines", entry0.getSubstring().equalsIgnoreCase("aabbbbaaaa"));

    sax = SAXFactory.ts2saxZnormByCuts(timeSeries01, 2, 2, cut);
    i = sax.iterator();
    entry0 = i.next();
    SAXFrequencyEntry entry1 = i.next();
    assertFalse("Testing SAX routines", entry0.getSubstring().equalsIgnoreCase(
        entry1.getSubstring()));

    // test double[] version here
    double[] data = new double[timeSeries01.size()];
    for (int k = 0; k < data.length; k++) {
      data[k] = timeSeries01.elementAt(k).value();
    }

    sax = SAXFactory.ts2saxZnormByCuts(data, 14, 10, cut);
    i = sax.iterator();
    entry0 = i.next();
    assertTrue("Testing SAX routines", entry0.getSubstring().equalsIgnoreCase("aabbbbaaaa"));

  }

  /**
   * Test the SAX conversion when NaN's presented in the timeseries.
   *
   * @throws Exception if error occurs.
   */
  @Test
  public void testTs2saxNoZnormByCuts() throws Exception {
    //
    // get series
    Timeseries ts1 = TSUtils.readTS(ts1File, length);
    Timeseries ts2 = TSUtils.readTS(ts2File, length);

    //
    // convert to sax with 2 letters alphabet and internal normalization
    double[] cut = { 0.0D };
    //SAXFrequencyData sax = SAXFactory.ts2saxNoZnormByCuts(ts1, 14, 10, cut);
    //Iterator<SAXFrequencyEntry> i = sax.iterator();
    //SAXFrequencyEntry entry0 = i.next();
    //assertTrue("Testing SAX routines", entry0.getSubstring().equalsIgnoreCase("bbbbbbbbbb"));

    //
    // now add two negatives
    ts1.elementAt(5).setValue(-5.0D);
    ts1.elementAt(4).setValue(-5.0D);
    SAXFrequencyData sax = SAXFactory.ts2saxNoZnormByCuts(ts1, 14, 10, cut);
    Iterator<SAXFrequencyEntry> i = sax.iterator();
    SAXFrequencyEntry entry0 = i.next();
    
    String expected = "bbabbbbbbb";
    String expected_shippable = "bbbabbbbbb";
    String actual = entry0.getSubstring().toLowerCase();

    System.out.println(String.format("expected[%s]  actual[%s]", expected, actual));
    
    assertEquals("Testing SAX routines", expected, actual);

    //
    //
    //sax = SAXFactory.ts2saxNoZnormByCuts(ts1, 2, 2, cut);
    //i = sax.iterator();
    //entry0 = i.next();
    //SAXFrequencyEntry entry1 = i.next();
    //System.out.println("entry0.getSubstring().equalsIgnoreCase(entry1.getSubstring()): " + entry0.getSubstring().equalsIgnoreCase(entry1.getSubstring()));
    //assertFalse("Testing SAX routines", entry0.getSubstring().equalsIgnoreCase(entry1.getSubstring()));
  }

  /**
   * Test the distance function (between strings).
   */
  @Ignore
  @Test
  public void testStrDistance() {
    assertEquals("Testing StrDistance", 1, SAXFactory.strDistance('a', 'b'));
    assertEquals("Testing StrDistance", 5, SAXFactory.strDistance('a', 'f'));
  }

}
