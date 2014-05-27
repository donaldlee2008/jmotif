package edu.hawaii.jmotif.sequitur;

/**
 * Container class for storing the SAX words/subsequences
 * 
 * 
 * @author Manfred Lerner
 *
 */
public class SAXSubsequence {
	int posIndex;
	String subsequence;
	
	/**
	 * @return position index
	 */
	public int getPosIndex() {
		return posIndex;
	}
	
	/**
	 * @param posIndex position index
	 */
	public void setPosIndex(int posIndex) {
		this.posIndex = posIndex;
	}
	
	/**
	 * @return SAX subsequence
	 */
	public String getSubsequence() {
		return subsequence;
	}
	
	/**
	 * @param subsequence SAX subsequence
	 */
	public void setSubsequence(String subsequence) {
		this.subsequence = subsequence;
	}
}
