package edu.hawaii.jmotif.sequitur;

import java.util.ArrayList;
import java.util.Arrays;

/**
 * Data container for SAX rules. For me (seninp) it is not really clear its utility for now, since
 * it can be substituted by the rule itself, but we use this to send rules to display.
 * 
 * @author Manfred Lerner, seninp
 * 
 */
public class SAXRuleRecord {

  // rule number
  private int ruleIndex;

  // Sequitur frequency - i.e. how many time it is used
  private int ruleUsageFrequency;

  private String ruleName;

  private String ruleString;

  private String expandedRuleString;

  private Integer length;

  private ArrayList<Integer> indexes = new ArrayList<Integer>();

  /**
   * @return index of the rule
   */
  public int getRuleIndex() {
    return ruleIndex;
  }

  public Integer getLength() {
    return length;
  }

  public void setLength(Integer length) {
    this.length = length;
  }

  /**
   * @param ruleIndex index of the rule
   */
  public void setRuleIndex(int ruleIndex) {
    this.ruleIndex = ruleIndex;
  }

  /**
   * @return frequency of the rule
   */
  public int getRuleFrequency() {
    return ruleUsageFrequency;
  }

  /**
   * @param ruleFrequency frequency of the rule
   */
  public void setRuleFrequency(int ruleFrequency) {
    this.ruleUsageFrequency = ruleFrequency;
  }

  /**
   * @return name of the rule, something like R1 or R30 etc.
   */
  public String getRuleName() {
    return ruleName;
  }

  /**
   * @param ruleName set the name of the rule, something like R1 or R30 etc.
   */
  public void setRuleName(String ruleName) {
    this.ruleName = ruleName;
  }

  /**
   * @return textual representation of the rule
   */
  public String getRuleString() {
    return ruleString;
  }

  /**
   * @param ruleString textual representation of the rule
   */
  public void setRuleString(String ruleString) {
    this.ruleString = ruleString;
  }

  /**
   * @return expanded textual representation of the rule
   */
  public String getExpandedRuleString() {
    return expandedRuleString;
  }

  /**
   * @param expandedRuleString expanded textual representation of the rule
   */
  public void setExpandedRuleString(String expandedRuleString) {
    this.expandedRuleString = expandedRuleString;
  }

  public String getOccurenceIndexes() {
    return Arrays.toString(this.indexes.toArray(new Integer[this.indexes.size()]));
  }

  public ArrayList<Integer> getIndexes() {
    return this.indexes;
  }

  public void setIndexes(int[] indexes) {
    this.indexes = new ArrayList<Integer>();
    for (Integer i : indexes) {
      this.indexes.add(i);
    }
  }

}
