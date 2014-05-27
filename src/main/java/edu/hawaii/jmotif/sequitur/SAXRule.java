package edu.hawaii.jmotif.sequitur;

/*
 This class is part of a Java port of Craig Nevill-Manning's Sequitur algorithm.
 Copyright (C) 1997 Eibe Frank

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Hashtable;
import java.util.Set;
import java.util.TreeSet;
import java.util.Vector;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * The Rule. Adaption of Eibe Frank code for JMotif API, see {@link sequitur.info} for original
 * version.
 * 
 * @author Manfred Lerner, seninp
 * 
 */
public class SAXRule {

  //
  // The rule utility constraint demands that a rule be deleted if it is referred to only once. Each
  // rule has an associated reference count, which is incremented when a non-terminal symbol that
  // references the rule is created, and decremented when the non-terminal symbol is deleted. When
  // the reference count falls to one, the rule is deleted.

  /** This is static - the global rule enumerator counter. */
  protected static AtomicInteger numRules;

  /** Guard symbol to mark beginning and end of rule. */
  protected SAXGuard theGuard;

  /** Counter keeps track of how many times the rule is used in the grammar. */
  protected int count;

  /** The rule's number. Used for identification of non-terminals. */
  protected int ruleIndex;

  /** Index used for printing. */
  protected int index;

  /**
   * This keeps rule indexes - once rule created or used, its placement position is extracted from
   * the TerminalSymbol position and stored here.
   */
  protected static Set<Integer> indexes = new TreeSet<Integer>();

  /**
   * Yet another, global static structure allowing fast rule access, ADD-ON by seninp to the
   * original code.
   */
  protected static Hashtable<Integer, SAXRule> theRules = new Hashtable<Integer, SAXRule>();

  /** Keeper for rules references, ADD-ON by Manfred to the original code. */
  // protected static ArrayList<String> arrayRuleStrings = new ArrayList<String>();

  protected static ArrayList<SAXRuleRecord> arrSAXRuleRecords = new ArrayList<SAXRuleRecord>();

  /**
   * Constructor.
   */
  public SAXRule() {

    // assign a next number to this rule and increment the global counter
    this.ruleIndex = numRules.intValue();
    numRules.incrementAndGet();

    // create a Guard handler for the rule
    synchronized (this) {
      this.theGuard = new SAXGuard(this);
    }
    if (null == this.theGuard) {
      System.out.println("gotcha 1");
    }
    // init other vars
    this.count = 0;
    this.index = 0;

    // save the instance
    theRules.put(this.ruleIndex, this);
  }

  /**
   * Report the FIRST symbol of the rule.
   * 
   * @return the FIRST rule's symbol.
   */
  public SAXSymbol first() {
    if (null == this.theGuard) {
      System.out.println(theRules.values());
      System.out.println("gotcha 2");
    }
    return this.theGuard.n;
  }

  /**
   * Report the LAST symbol of the rule.
   * 
   * @return the LAST rule's symbol.
   */
  public SAXSymbol last() {
    return this.theGuard.p;
  }

  /**
   * Original getRules() method. Prints out rules. Funny, that in the original code it is only
   * possible to call it on the head - i.e. Grammar.
   * 
   * @return the formatted rules string.
   */
  public synchronized String getRules() {

    Vector<SAXRule> rules = new Vector<SAXRule>(numRules.intValue());
    SAXRule currentRule;
    SAXRule referedTo;
    SAXSymbol sym;
    int index;
    int processedRules = 0;
    StringBuffer text = new StringBuffer();

    text.append("Usage\tRule\n");
    rules.addElement(this);

    // add-on - keeping the rule string, will be used in order to expand rules
    StringBuilder currentRuleString = new StringBuilder();

    while (processedRules < rules.size()) {
      currentRule = rules.elementAt(processedRules);
      text.append(" ");
      text.append(currentRule.count);
      text.append("\tR");
      text.append(processedRules);
      text.append(" -> ");
      for (sym = currentRule.first(); (!sym.isGuard()); sym = sym.n) {
        if (sym.isNonTerminal()) {
          referedTo = ((SAXNonTerminal) sym).r;
          if ((rules.size() > referedTo.index) && (rules.elementAt(referedTo.index) == referedTo)) {
            index = referedTo.index;
          }
          else {
            index = rules.size();
            referedTo.index = index;
            rules.addElement(referedTo);
          }
          text.append('R');
          text.append(index);

          currentRuleString.append('R');
          currentRuleString.append(index);
        }
        else {
          if (sym.value.equals(" ")) {
            text.append('_');
            currentRuleString.append('_');
          }
          else {
            if (sym.value.equals("\n")) {
              text.append("\\n");
              currentRuleString.append("\\n");
            }
            else {
              text.append(sym.value);
              currentRuleString.append(sym.value);
            }
          }
        }
        text.append(' ');
        currentRuleString.append(' ');
      }
      // seninp: adding to original output rule occurrence indexes
      //
      text.append("\tidx:");
      text.append(Arrays.toString(currentRule.getIndexes()));
      //
      // and rules map fill-in
      // arrayRuleStrings.add(currentRuleString.toString());
      currentRuleString = new StringBuilder();

      text.append('\n');
      processedRules++;
    }
    return text.toString();
  }

  /**
   * Add-on to the original code by manfred and seninp. This one similar to the original getRules()
   * but populates and returns the array list of SAXRuleRecords.
   * 
   * @return list of SAXRuleRecords.
   */
  public synchronized ArrayList<SAXRuleRecord> getSAXRules() {

    Vector<SAXRule> rules = new Vector<SAXRule>(numRules.intValue());
    SAXRule currentRule;
    SAXRule referedTo;
    SAXSymbol sym;
    int index;
    int processedRules = 0;
    StringBuffer text = new StringBuffer();

    text.append("Usage\tRule\n");
    rules.addElement(this);
    StringBuilder sbCurrentRule = new StringBuilder();

    while (processedRules < rules.size()) {
      currentRule = rules.elementAt(processedRules);
      text.append(" ");
      text.append(currentRule.count);
      text.append("\tR");
      text.append(processedRules);
      text.append(" -> ");
      for (sym = currentRule.first(); (!sym.isGuard()); sym = sym.n) {
        if (sym.isNonTerminal()) {
          referedTo = ((SAXNonTerminal) sym).r;
          if ((rules.size() > referedTo.index) && (rules.elementAt(referedTo.index) == referedTo)) {
            index = referedTo.index;
          }
          else {
            index = rules.size();
            referedTo.index = index;
            rules.addElement(referedTo);
          }
          text.append('R');
          text.append(index);

          sbCurrentRule.append('R');
          sbCurrentRule.append(index);
        }
        else {
          if (sym.value.equals(" ")) {
            text.append('_');
            sbCurrentRule.append('_');
          }
          else {
            if (sym.value.equals("\n")) {
              text.append("\\n");
              sbCurrentRule.append("\\n");
            }
            else {
              text.append(sym.value);
              sbCurrentRule.append(sym.value);
            }
          }
        }
        text.append(' ');
        sbCurrentRule.append(' ');
      }

      // TODO: seninp: adding occurrence indexes
      //
      text.append("\tidx:");
      text.append(Arrays.toString(currentRule.getIndexes()));
      text.append('\n');

      // System.out.println(text.toString());
      SAXRuleRecord saxContainer = new SAXRuleRecord();
      saxContainer.setRuleIndex(processedRules);
      saxContainer.setRuleFrequency(currentRule.count);
      saxContainer.setRuleName("R" + processedRules);
      saxContainer.setRuleString(sbCurrentRule.toString());
      saxContainer.setIndexes(currentRule.getIndexes());
      arrSAXRuleRecords.add(saxContainer);

      sbCurrentRule = new StringBuilder();
      processedRules++;
    }

    expandRules();
    // computeRuleOffsets();
    return arrSAXRuleRecords;
  }

  /**
   * Manfred's cool trick to get out all expanded rules. Expands the rule of each SAX container into
   * SAX words string.
   * 
   * @return
   */
  public synchronized void expandRules() {

    // vars
    int currentPositionIndex = 0;
    int workIndex = 0;
    String resultString = null;
    SAXRuleRecord saxContainer = null;

    // iterate over all SAX containers
    for (currentPositionIndex = 0; currentPositionIndex < arrSAXRuleRecords.size(); currentPositionIndex++) {

      saxContainer = arrSAXRuleRecords.get(currentPositionIndex);
      resultString = saxContainer.getRuleString();

      // here it goes over the rule string iteratively expanding the rules. trick is that rules
      // start with "R"
      //
      workIndex = 0;
      while (resultString.contains("R")) {
        resultString = resultString.replaceAll("R" + workIndex + " ",
            arrSAXRuleRecords.get(workIndex).getRuleString());
        if (workIndex == arrSAXRuleRecords.size() - 1)
          workIndex = 0;
        ++workIndex;
      }

      // need to trim space at the very end
      saxContainer.setExpandedRuleString(resultString.trim());
    }

  }

  public synchronized ArrayList<SAXRuleRecord> getSAXContainerList() {
    return arrSAXRuleRecords;
  }

  public void addIndex(int position) {
    indexes.add(position);
  }

  private int[] getIndexes() {
    int[] res = new int[indexes.size()];

    int i = 0;
    for (Integer idx : indexes) {
      res[i] = idx;
      i++;
    }
    return res;
  }

  public String getGrammarDisplayString() {

    Vector<SAXRule> rules = new Vector<SAXRule>(numRules.intValue());
    SAXRule referedTo;
    SAXSymbol sym;
    int index;
    StringBuffer text = new StringBuffer();

    text.append("Usage\tRule\n");
    rules.addElement(this);

    StringBuilder sbCurrentRule = new StringBuilder();
    SAXRule currentRule = rules.get(0);

    for (sym = currentRule.first(); (!sym.isGuard()); sym = sym.n) {
      if (sym.isNonTerminal()) {
        referedTo = ((SAXNonTerminal) sym).r;
        if ((rules.size() > referedTo.index) && (rules.elementAt(referedTo.index) == referedTo)) {
          index = referedTo.index;
        }
        else {
          index = rules.size();
          referedTo.index = index;
          rules.addElement(referedTo);
        }
        text.append('R');
        text.append(index);

        sbCurrentRule.append('R');
        sbCurrentRule.append(index);
      }
      else {
        if (sym.value.equals(" ")) {
          text.append('_');
          sbCurrentRule.append('_');
        }
        else {
          if (sym.value.equals("\n")) {
            text.append("\\n");
            sbCurrentRule.append("\\n");
          }
          else {
            text.append(sym.value);
            sbCurrentRule.append(sym.value);
          }
        }
      }
      text.append(' ');
      sbCurrentRule.append(' ');
    }
    
    return sbCurrentRule.toString();
  }

}
