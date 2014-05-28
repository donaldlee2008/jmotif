package edu.hawaii.jmotif.sax;

import edu.hawaii.jmotif.text.TextUtils;
import edu.hawaii.jmotif.text.WordBag;
import static org.junit.Assert.assertTrue;
import java.util.HashMap;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;

/**
 * Test the text utilities class.
 * 
 * @author psenin
 * 
 */
public class TestTextUtils {

  private static final String[][] BAG1 = { 
      { "the", "3" }, 
      { "brown", "5" }, 
      { "cow", "2" } };
  
  private static final String[][] BAG2 = { 
      { "the", "3" }, 
      { "green", "2" }, 
      { "hill", "3" },
      { "cow", "2" }, 
      { "grass", "4" } };
  
  private static final String[][] BAG3 = { 
      { "the", "3" }, 
      { "hill", "2" }, 
      { "meadow", "4" },
      { "cow", "4" }, 
      { "air", "2" } };

  private WordBag bag1;
  private WordBag bag2;
  private WordBag bag3;
  private HashMap<String, WordBag> bags;

  /**
   * Test set-up.
   */
  @Before
  public void setUp() {
    bag1 = buildBag("bag1", BAG1);
    bag2 = buildBag("bag2", BAG2);
    bag3 = buildBag("bag3", BAG3);
    bags = new HashMap<String, WordBag>();
    bags.put(bag1.getLabel(), bag1);
    bags.put(bag2.getLabel(), bag2);
    bags.put(bag3.getLabel(), bag3);
  }

  /**
   * Test the term frequency method.
   */
  @Ignore
  @Test
  public void testTF() {
    assertTrue(Double.valueOf(3.0D / 5D).doubleValue() == TextUtils.normalizedTF(bag1, BAG1[0][0]));
    assertTrue(Double.valueOf(2.0D / 4D).doubleValue() == TextUtils.normalizedTF(bag2, BAG2[1][0]));
    assertTrue(Double.valueOf(4.0D / 4D).doubleValue() == TextUtils.normalizedTF(bag3, BAG3[3][0]));
  }

  /**
   * Test the document frequency method.
   */
  @Ignore
  @Test
  public void testDF() {
    assertTrue(3 == TextUtils.df(bags, "the"));
    assertTrue(1 == TextUtils.df(bags, "meadow"));
  }

  /**
   * Test inverse document frequency method.
   */
  @Ignore
  @Test
  public void testIDF() {
    assertTrue(Double.POSITIVE_INFINITY == TextUtils.idf(bags, "non"));
    assertTrue(1.0D == TextUtils.idf(bags, "the"));
    assertTrue(3.0D / 2.0D == TextUtils.idf(bags, "hill"));
    assertTrue(3.0D / 1.0D == TextUtils.idf(bags, "air"));
  }

  @Ignore
  @Test
  public void testTFIDF_bag1_the() {
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags.values());
    assertTrue(0.0D == tfidf.get("bag1").get("the"));
  }

  /**
   * Test tf-idf statistics.
   */
  @Ignore
  @Test
  public void testTFIDF() {
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags.values());

    double tfHill2 = TextUtils.logTF(bag2, "hill");

    double idfHill = TextUtils.idf(bags, "hill");

    double tfidfHill2 = tfHill2 * Math.log10(idfHill);

    System.out.println("\ntfHill2: " + tfHill2);
    System.out.println("idfHill: " + idfHill);
    System.out.println("tfidfHill2: " + tfidfHill2);
    System.out.println("tfidf.get(\"bag2\").get(\"hill\"): " + tfidf.get("bag2").get("hill"));
    assertTrue(tfidfHill2 == tfidf.get("bag2").get("hill"));
  }

  @Ignore
  @Test
  public void testTFIDF_bag3_hill() {
    HashMap<String, HashMap<String, Double>> tfidf = TextUtils.computeTFIDF(bags.values());

    double idfHill = TextUtils.idf(bags, "hill");
    double tfHill3 = TextUtils.logTF(bag3, "hill");
    double tfidfHill3 = tfHill3 * Math.log10(idfHill);

    System.out.println("\ntfHill3: " + tfHill3);
    System.out.println("idfHill: " + idfHill);
    System.out.println("tfidfHill3: " + tfidfHill3);
    System.out.println("tfidf.get(\"bag3\").get(\"hill\"): " + tfidf.get("bag3").get("hill"));
    
    assertTrue(tfidfHill3 == tfidf.get("bag3").get("hill"));
  }

  /**
   * private method for building test bag objects.
   * 
   * @param name The bag name.
   * @param data The test data.
   * @return The wordBag class.
   */
  private WordBag buildBag(String name, String[][] data) {
    WordBag res = new WordBag(name);
    for (String[] d : data) {
      res.addWord(d[0], Integer.valueOf(d[1]));
    }
    return res;
  }

}
