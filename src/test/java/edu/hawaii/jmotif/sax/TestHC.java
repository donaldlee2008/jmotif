package edu.hawaii.jmotif.sax;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import java.util.HashMap;
import org.junit.Before;
import org.junit.Test;
import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.cluster.Cluster;
import edu.hawaii.jmotif.text.cluster.HC;
import edu.hawaii.jmotif.text.cluster.LinkageCriterion;

/**
 * Test the HC class.
 * 
 * @author psenin
 * 
 */
public class TestHC {

  private static final Double[] a = { 0.1, 0.2, 0.3, 0.4 };
  private static final Double[] b = { 0.1, 0.3, 0.3, 0.4 };
  private static final Double[] c = { 0.4, 0.8, 0.9, 0.4 };
  private static final Double[] d = { 0.3, 0.7, 0.7, 0.4 };

  private static final Double[] a1 = { 0.1, 0.2, 0.3, 0.4 };
  private static final Double[] b1 = { 0.1, 0.3, 0.3, 0.4 };
  private static final Double[] c1 = { 0.4, 0.8, 0.9, 0.4 };
  private static final Double[] d1 = { 0.4, 0.2, 0.7, 0.4 };

  private static final String[] words = { "a", "b", "c", "d" };

  private HashMap<String, HashMap<String, Double>> data;
  private HashMap<String, HashMap<String, Double>> data1;

  @Before
  public void setUp() {
    data = new HashMap<String, HashMap<String, Double>>();
    data.put(words[0], makeMap(words, a));
    data.put(words[1], makeMap(words, b));
    data.put(words[2], makeMap(words, c));
    data.put(words[3], makeMap(words, d));

    data1 = new HashMap<String, HashMap<String, Double>>();
    data1.put(words[0], makeMap(words, a1));
    data1.put(words[1], makeMap(words, b1));
    data1.put(words[2], makeMap(words, c1));
    data1.put(words[3], makeMap(words, d1));
  }

  @Test
  public void testDotProduct() {
    assertEquals(TextUtils.dotProduct(a, b), 0.32D, 0.0001);
    assertEquals(TextUtils.dotProduct(c, b), 0.71D, 0.0001);
    assertEquals(TextUtils.magnitude(c), 1.330413D, 0.0001);
  }

  @Test
  public void testHC() {
    Cluster c = HC.Hc(data, LinkageCriterion.SINGLE);
    System.out.println(c.toNewick());
    assertNotNull(c);

    Cluster c1 = HC.Hc(data1, LinkageCriterion.SINGLE);
    System.out.println(c1.toNewick());
    assertNotNull(c1);
  }

  private HashMap<String, Double> makeMap(String[] words, Double[] weights) {
    HashMap<String, Double> res = new HashMap<String, Double>();
    int i = 0;
    for (String w : words) {
      res.put(w, weights[i]);
      i++;
    }
    return res;
  }
}
