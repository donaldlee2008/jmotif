package edu.hawaii.jmotif.sax;

import edu.hawaii.jmotif.sax.datastructures.SAXDataEntry;
import edu.hawaii.jmotif.sax.datastructures.SAXFrequencyEntry;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import java.util.ArrayList;
import org.junit.Test;

/**
 * Test data structures used in the SAX implementation.
 * 
 * @author Pavel Senin.
 * 
 */
public class TestSAXDataStructures {

  private static final Integer iNum1 = 7;
  private static final Integer iNum2 = 3;
  private static final String str11 = "abggfecbb";

  /**
   * Test the SAX entry structure.
   */
  @Test
  public void testSAXEntry() {
    SAXDataEntry se = new SAXDataEntry(str11, iNum1);
    assertEquals("Testing SAXEntry.", iNum1, se.getIdx());
    assertEquals("Testing SAXEntry.", str11, se.getStr());
  }

  /**
   * Test the SAX frequency structure.
   */
  @Test
  public void testSAXFrequencyEntry() {
    SAXFrequencyEntry se = new SAXFrequencyEntry(str11, iNum2);

    assertTrue("Testing SAXFrequencyEntry.", str11.equalsIgnoreCase(se.getSubstring()));

    ArrayList<Integer> freqs = se.getEntries();
    assertEquals("Testing SAXFrequencyEntry.", 1, freqs.size());
    assertEquals("Testing SAXFrequencyEntry.", iNum2, freqs.get(0));

    se.put(iNum1);
    ArrayList<Integer> freqs1 = se.getEntries();
    assertEquals("Testing SAXFrequencyEntry.", 2, freqs1.size());
    assertEquals("Testing SAXFrequencyEntry.", iNum2, freqs1.get(0));
    assertEquals("Testing SAXFrequencyEntry.", iNum1, freqs1.get(1));

    se.put(iNum2);
    ArrayList<Integer> freqs2 = se.getEntries();
    assertEquals("Testing SAXFrequencyEntry.", 2, freqs2.size());
    assertEquals("Testing SAXFrequencyEntry.", iNum2, freqs2.get(0));
    assertEquals("Testing SAXFrequencyEntry.", iNum1, freqs2.get(1));
  }

}
