package edu.hawaii.jmotif.sax;

import edu.hawaii.jmotif.sax.trie.VisitRegistry;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import org.junit.Before;
import org.junit.Test;

/**
 * Test the visit registry.
 *
 * @author psenin
 *
 */
public class TestVisitRegistry {

  private VisitRegistry vr;

  /**
   * Set up.
   *
   * @throws Exception if error occurs.
   */
  @Before
  public void setUp() throws Exception {
    vr = new VisitRegistry(13);
  }

  /**
   * Test the constructor.
   */
  @Test
  public void testVisitRegistry() {
    assertEquals("Test visit registry", 13, vr.getUnvisited().size());
    assertTrue("Test visit registry", vr.getVisited().isEmpty());
  }

  /**
   * Test the marking.
   */
  @Test
  public void testMarkVisited() {
    vr.markVisited(3);
    vr.markVisited(7);

    assertEquals("Test visit registry", 11, vr.getUnvisited().size());
    assertFalse("Test visit registry", vr.getUnvisited().contains(3));
    assertFalse("Test visit registry", vr.getUnvisited().contains(7));

    assertEquals("Test visit registry", 2, vr.getVisited().size());
    assertTrue("Test visit registry", vr.getVisited().contains(3));
    assertTrue("Test visit registry", vr.getVisited().contains(7));
  }

  /**
   * Test the position generator.
   */
  @Test
  public void testGetNextRandomUnvisitedPosition() {
    int k = vr.getNextRandomUnvisitedPosition();
    assertTrue("Test visit registry", vr.getUnvisited().contains(k));
    assertFalse("Test visit registry", vr.getVisited().contains(k));
    vr.markVisited(k);
    assertFalse("Test visit registry", vr.getUnvisited().contains(k));

    int i = 0;
    while (!vr.getUnvisited().isEmpty()) {
      k = vr.getNextRandomUnvisitedPosition();
      assertFalse("Test visit registry", vr.getVisited().contains(k));
      vr.markVisited(k);
      assertFalse("Test visit registry", vr.getUnvisited().contains(k));
      i++;
    }
    assertEquals("Test visit registry", 12, i);
  }

}
