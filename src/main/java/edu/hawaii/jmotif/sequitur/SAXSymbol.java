package edu.hawaii.jmotif.sequitur;

/*
 This class was modified from a Java port of Craig Nevill-Manning's Sequitur algorithm.
 Copyright (C) 1997 Eibe Frank
 */

import java.util.Hashtable;

/**
 * Template for Sequitur data structures. Adaption of Eibe Frank code for JMotif API, see
 * {@link sequitur.info} for original version.
 * 
 * @author Manfred Lerner, seninp
 * 
 */
public abstract class SAXSymbol {

  /**
   * Apparently, this limits the possible number of terminals, ids of non-terminals start after this
   * num.
   */
  protected static final int numTerminals = 100000;

  /** Seed the size of hash table? */
  private static final int prime = 2265539;

  /** Hashtable to keep track of all digrams. This is static - single instance for all. */
  protected static Hashtable<SAXSymbol, SAXSymbol> theDigrams = new Hashtable<SAXSymbol, SAXSymbol>(
      SAXSymbol.prime);

  /** The symbol value. */
  protected String value;

  /** The symbol original position. */
  protected int originalPosition;

  /** Sort of pointers for previous and the next symbols. */
  protected SAXSymbol n, p;

  /**
   * Links two symbols together, removing any old digram from the hash table.
   * 
   * @param left the left symbol.
   * @param right the right symbol.
   */
  public static synchronized void join(SAXSymbol left, SAXSymbol right) {

    // check for an OLD digram existence - i.e. left must have a next symbol
    // if .n exists then we are joining TERMINAL symbols within the string, and must clean-up the
    // old digram
    if (left.n != null) {
      left.deleteDigram();
    }

    // re-link left and right
    left.n = right;
    right.p = left;
  }

  /**
   * Cleans up template.
   */
  public abstract void cleanUp();

  /**
   * Inserts a symbol after this one.
   * 
   * @param toInsert the new symbol to be inserted.
   */
  public synchronized void insertAfter(SAXSymbol toInsert) {

    // call join on this symbol' NEXT - placing it AFTER the new one
    join(toInsert, n);

    // call join on THIS symbol placing the NEW AFTER
    join(this, toInsert);
  }

  /**
   * Removes the digram from the hash table. Overwritten in sub class guard.
   */
  public synchronized void deleteDigram() {

    // if N is a Guard - then it is a RULE sits here, don't care about digram
    if (n.isGuard()) {
      return;
    }

    // delete digram if its exactly this one
    if (this == theDigrams.get(this)) {
      theDigrams.remove(this);
    }
  }

  /**
   * Returns true if this is the guard symbol. Overwritten in subclass guard.
   */
  public boolean isGuard() {
    return false;
  }

  /**
   * Returns true if this is a non-terminal. Overwritten in subclass nonTerminal.
   */
  public boolean isNonTerminal() {
    return false;
  }

  /**
   * "Checks in" a new digram and enforce the digram uniqueness constraint. If it appears elsewhere,
   * deals with it by calling match(), otherwise inserts it into the hash table. Overwritten in
   * subclass guard.
   * 
   * @return true if it is not unique.
   */
  public synchronized boolean check() {

    // System.out.println("[sequitur debug] *calling check() on* " + this.value + ", n isGuard: "
    // + n.isGuard());

    // ... Each time a link is made between two symbols if the new digram is repeated elsewhere
    // and the repetitions do not overlap, if the other occurrence is a complete rule,
    // replace the new digram with the non-terminal symbol that heads the rule,
    // otherwise,form a new rule and replace both digrams with the new non-terminal symbol
    // otherwise, insert the digram into the index...

    if (n.isGuard()) {
      // i am the rule
      return false;
    }

    if (!theDigrams.containsKey(this)) {
      // System.out.println("[sequitur debug] *check...* digrams contain this (" + this.value + "~"
      // + this.n.value + ")? NO. Checking in.");
      // found = theDigrams.put(this, this);
      theDigrams.put(this, this);
      // System.out.println("[sequitur debug] *digrams* " + hash2String());
      return false;
    }

    // System.out.println("[sequitur debug] *check...* digrams contain this (" + this.value
    // + this.n.value + ")? Yes. Oh-Oh...");

    // well the same hash is in the store, lemme see...
    SAXSymbol found = theDigrams.get(this);

    // if it's not me, then lets call match magic?
    if (found.n != this) {
      // System.out.println("[sequitur debug] *double check...* IT IS NOT ME!");
      match(this, found);
    }

    return true;
  }

  /**
   * Replace a digram with a non-terminal.
   */
  public synchronized void substitute(SAXRule r) {
    // System.out.println("[sequitur debug] *substitute* " + this.value + " with rule "
    // + r.asDebugLine());
    // clean up this place and the next

    r.addIndex(this.originalPosition);

    this.cleanUp();
    this.n.cleanUp();
    // link the rule instead of digram
    SAXNonTerminal nt = new SAXNonTerminal(r);
    nt.originalPosition = this.originalPosition;
    this.p.insertAfter(nt);
    // do p check
    //
    // TODO: not getting this
    if (!p.check()) {
      p.n.check();
    }
  }

  /**
   * Deals with a matching digram.
   * 
   * @param
   */
  public synchronized void match(SAXSymbol newDigram, SAXSymbol matchingDigram) {

    SAXRule rule;
    SAXSymbol first, second;

    // System.out.println("[sequitur debug] *match* newDigram [" + newDigram.value + ","
    // + newDigram.n.value + "], old matching one [" + matchingDigram.value + ","
    // + matchingDigram.n.value + "]");

    // if previous of matching digram is a guard
    if (matchingDigram.p.isGuard() && matchingDigram.n.n.isGuard()) {
      // reuse an existing rule
      rule = ((SAXGuard) matchingDigram.p).r;
      newDigram.substitute(rule);
    }
    else {
      // string built of the normal terminal symbols here?
      // create a new rule
      rule = new SAXRule();

      try {

        // tie the digram's links together within the new rule
        // this uses copies of objects, so they do not get cut out of S
        first = (SAXSymbol) newDigram.clone();
        second = (SAXSymbol) newDigram.n.clone();
        rule.theGuard.n = first;
        first.p = rule.theGuard;
        first.n = second;
        second.p = first;
        second.n = rule.theGuard;
        rule.theGuard.p = second;

        // System.out.println("[sequitur debug] *newRule...* \n" + rule.getRules());

        // put this digram into the hash
        // this effectively erases the OLD MATCHING digram with the new DIGRAM (symbol is wrapped
        // into Guard)
        theDigrams.put(first, first);

        // substitute the matching (old) digram with this rule in S
        // System.out.println("[sequitur debug] *newRule...* substitute OLD digram first.");
        matchingDigram.substitute(rule);

        // substitute the new digram with this rule in S
        // System.out.println("[sequitur debug] *newRule...* substitute NEW digram last.");
        newDigram.substitute(rule);

      }
      catch (CloneNotSupportedException c) {
        c.printStackTrace();
      }
    }

    // Check for an underused rule.

    if (rule.first().isNonTerminal() && (((SAXNonTerminal) rule.first()).r.count == 1))
      ((SAXNonTerminal) rule.first()).expand();
  }

  /**
   * Custom hashcode implementation. Produces the hashcode for a digram using this and the next
   * symbol.
   * 
   * @return the digram's hash code.
   */
  public int hashCode() {
    int hash1 = 31;
    int hash2 = 13;
    int num0 = 0;

    for (int i = 0; i < value.length(); i++) {
      num0 = num0 + Character.getNumericValue(value.charAt(i));
    }

    int num1 = 0;

    for (int i = 0; i < n.value.length(); i++) {
      num1 = num1 + Character.getNumericValue(n.value.charAt(i));
    }

    hash2 = num0 * hash1 + hash2 * num1;
    return hash2;
  }

  /**
   * Test if two digrams are equal. WARNING: don't use to compare two symbols.
   */
  public boolean equals(Object obj) {
    if (this == obj)
      return true;
    if (obj == null)
      return false;
    if (!(obj instanceof SAXSymbol))
      return false;
    // return ((value == ((SAXSymbol)obj).value) &&
    // (n.value == ((SAXSymbol)obj).n.value));
    return ((value.equals(((SAXSymbol) obj).value)) && (n.value.equals(((SAXSymbol) obj).n.value)));
  }

  @Override
  public String toString() {
    return "SAXSymbol [value=" + value + ", p=" + p + ", n=" + n + "]";
  }

}
