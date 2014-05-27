package edu.hawaii.jmotif.performance.digits;

/*
 * MooreNeighbor.java
 *
 * Created on 26 noiembrie 2005, 23:13
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

/**
 *
 * @author Strainu
 */
import java.awt.Graphics;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Point;
import java.util.ArrayList;
import java.util.Arrays;
import javax.swing.JButton;
import javax.swing.JPanel;

public class MooreNeighbor extends javax.swing.JApplet {

  private static double[] dat = {

    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 87.0, 173.0, 162.0, 151.0, 76.0, 0.0, 11.0, 21.0, 87.0, 152.0, 152.0, 152.0, 152.0, 152.0, 173.0, 193.0, 214.0, 234.0, 143.0, 51.0, 26.0, 0.0, 0.0, 0.0, 0.0, 0.0, 15.0, 31.0, 112.0, 193.0, 182.0, 171.0, 111.0, 51.0, 61.0, 72.0, 124.0, 177.0, 177.0, 177.0, 177.0, 177.0, 193.0, 208.0, 223.0, 239.0, 163.0, 86.0, 43.0, 0.0, 0.0, 0.0, 0.0, 0.0, 53.0, 123.0, 197.0, 253.0, 252.0, 232.0, 215.0, 203.0, 209.0, 223.0, 239.0, 253.0, 254.0, 252.0, 253.0, 253.0, 253.0, 252.0, 255.0, 253.0, 235.0, 192.0, 96.0, 0.0, 0.0, 0.0, 20.0, 32.0, 121.0, 212.0, 246.0, 255.0, 255.0, 251.0, 249.0, 248.0, 250.0, 252.0, 254.0, 255.0, 255.0, 255.0, 255.0, 255.0, 255.0, 254.0, 255.0, 254.0, 255.0, 238.0, 119.0, 0.0, 0.0, 0.0, 61.0, 123.0, 194.0, 249.0, 255.0, 254.0, 254.0, 254.0, 255.0, 255.0, 255.0, 255.0, 255.0, 255.0, 255.0, 253.0, 253.0, 254.0, 253.0, 253.0, 253.0, 254.0, 255.0, 253.0, 126.0, 0.0, 0.0, 0.0, 102.0, 215.0, 248.0, 254.0, 255.0, 253.0, 253.0, 254.0, 255.0, 255.0, 251.0, 247.0, 246.0, 248.0, 250.0, 252.0, 253.0, 253.0, 253.0, 252.0, 253.0, 254.0, 255.0, 247.0, 124.0, 0.0, 0.0, 0.0, 117.0, 234.0, 255.0, 253.0, 255.0, 254.0, 254.0, 253.0, 251.0, 244.0, 223.0, 203.0, 198.0, 203.0, 222.0, 243.0, 251.0, 254.0, 254.0, 253.0, 255.0, 254.0, 255.0, 233.0, 117.0, 0.0, 0.0, 0.0, 56.0, 109.0, 189.0, 255.0, 255.0, 255.0, 236.0, 198.0, 140.0, 84.0, 55.0, 40.0, 27.0, 36.0, 100.0, 173.0, 222.0, 253.0, 255.0, 252.0, 255.0, 241.0, 170.0, 96.0, 48.0, 0.0, 0.0, 0.0, 23.0, 37.0, 133.0, 224.0, 238.0, 214.0, 158.0, 92.0, 43.0, 7.0, 0.0, 0.0, 0.0, 4.0, 95.0, 191.0, 234.0, 254.0, 255.0, 255.0, 247.0, 214.0, 112.0, 25.0, 13.0, 0.0, 0.0, 0.0, 8.0, 13.0, 88.0, 159.0, 166.0, 137.0, 70.0, 5.0, 0.0, 0.0, 0.0, 0.0, 30.0, 82.0, 166.0, 242.0, 255.0, 254.0, 255.0, 248.0, 211.0, 156.0, 70.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 42.0, 81.0, 80.0, 61.0, 29.0, 0.0, 0.0, 0.0, 0.0, 0.0, 93.0, 193.0, 235.0, 252.0, 255.0, 253.0, 242.0, 212.0, 138.0, 61.0, 21.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 7.0, 14.0, 14.0, 10.0, 5.0, 0.0, 0.0, 0.0, 15.0, 55.0, 153.0, 245.0, 255.0, 253.0, 255.0, 255.0, 199.0, 121.0, 57.0, 10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 71.0, 156.0, 216.0, 255.0, 255.0, 255.0, 239.0, 201.0, 118.0, 38.0, 7.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 20.0, 61.0, 153.0, 239.0, 255.0, 253.0, 255.0, 239.0, 173.0, 96.0, 35.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 21.0, 116.0, 214.0, 246.0, 253.0, 255.0, 254.0, 224.0, 172.0, 81.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 45.0, 112.0, 188.0, 250.0, 255.0, 253.0, 255.0, 255.0, 175.0, 76.0, 25.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 19.0, 104.0, 194.0, 236.0, 255.0, 255.0, 255.0, 236.0, 196.0, 104.0, 17.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 25.0, 73.0, 162.0, 243.0, 255.0, 255.0, 255.0, 249.0, 175.0, 89.0, 32.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 70.0, 152.0, 211.0, 252.0, 255.0, 253.0, 246.0, 212.0, 103.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 120.0, 236.0, 255.0, 253.0, 255.0, 234.0, 150.0, 59.0, 17.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 41.0, 102.0, 188.0, 255.0, 255.0, 253.0, 238.0, 199.0, 95.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 95.0, 198.0, 238.0, 253.0, 255.0, 252.0, 200.0, 130.0, 54.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 99.0, 204.0, 242.0, 255.0, 255.0, 253.0, 149.0, 41.0, 7.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 15.0, 25.0, 130.0, 235.0, 255.0, 253.0, 255.0, 252.0, 191.0, 135.0, 159.0, 176.0, 91.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 49.0, 97.0, 180.0, 251.0, 255.0, 254.0, 255.0, 255.0, 225.0, 181.0, 150.0, 114.0, 53.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0, 10.0, 87.0, 174.0, 227.0, 255.0, 255.0, 255.0, 252.0, 231.0, 188.0, 130.0, 51.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 41.0, 41.0, 117.0, 193.0, 223.0, 252.0, 253.0, 253.0, 192.0, 130.0, 65.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0, 10.0, 29.0, 48.0, 56.0, 63.0, 63.0, 63.0, 48.0, 33.0, 16.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
  
  };

  /**
   * 
   */
  private static final long serialVersionUID = -6506079731650980743L;

  protected static final int STEP = 7;

  private static final int THRESHOLD =1;

  private static final int RUN_THRESHOLD = 150;
  public CanvasMatrice canvas = new CanvasMatrice();
  public JButton but = new JButton("Run MooreNeighbor");

  /** Creates a new instance of RadialSweep */
  public MooreNeighbor() {
  }

  public void paint(Graphics g) {

  }

  public void init() {
    setSize(780, 300);
    GridBagLayout grid = new GridBagLayout();
    setLayout(grid);
    canvas.setSize(600, 300);
    canvas.addMouseListener(new Matrice(canvas));

    // matrix
    int[][] mat = canvas.m1;
    for (int i = 0; i < dat.length; i++) {
      int row = i % 28;
      int col = i / 28;
      if (dat[i] < THRESHOLD) {
        mat[row][col] = 0;
      }
      else {
        mat[row][col] = 1;
      }

    }

    but.addActionListener(new java.awt.event.ActionListener() {
      public void actionPerformed(java.awt.event.ActionEvent evt) {

        Integer[] chain = algoritm();
        System.out.println(Arrays.toString(chain).replace("[", "").replace("]", "")
            .replace(",", ""));

        ArrayList<Double> curve = new ArrayList<Double>();
        ArrayList<Double> curve2 = new ArrayList<Double>();
        for (int i = 0; i < chain.length; i++) {
          int[] forwardHist = null;
          int[] backwardHist = null;

          if (i >= STEP && i < chain.length - STEP) {
            forwardHist = histogram(Arrays.copyOfRange(chain, i, i + STEP));
            backwardHist = histogram(Arrays.copyOfRange(chain, i - STEP, i));
          }
          else if (i < STEP) {
            forwardHist = histogram(Arrays.copyOfRange(chain, i, i + STEP));
            backwardHist = histogram(glue(
                Arrays.copyOfRange(chain, chain.length - (STEP - i), chain.length),
                Arrays.copyOfRange(chain, 0, i)));
          }
          else if (i >= chain.length - STEP) {
            forwardHist = histogram(glue(Arrays.copyOfRange(chain, i, chain.length),
                Arrays.copyOfRange(chain, 0, STEP - (chain.length - i))));
            backwardHist = histogram(Arrays.copyOfRange(chain, i - STEP, i));
          }

          double roi = roInverse(forwardHist, backwardHist);
          curve.add(roi);

          double ro2 = buildRo2(roi, forwardHist, backwardHist);
          curve2.add(ro2);
        }

        System.out.println(Arrays.toString(curve.toArray(new Double[curve.size()]))
            .replace("[", "").replace("]", ""));

        System.out.println(Arrays.toString(curve2.toArray(new Double[curve2.size()]))
            .replace("[", "").replace("]", ""));

      }

      private double buildRo2(double roi, int[] forwardHist, int[] backwardHist) {
        int modF = mod(forwardHist);
        int modG = mod(backwardHist);

        int i1 = (modG + 1) % 8;
        int i2 = (modG + 3) % 8;

        int i3 = (modG - 1) % 8;
        int i4 = (modG - 3) % 8;

        int sign = 1;
        // if (Math.min(i1, i2) <= modF && modF <= Math.max(i1, i2)) {
        // sign = 1;
        // }

        if (modF == modG) {
          return 0;
        }

        if (Math.min(i3, i4) <= modF && modF <= Math.max(i3, i4)) {
          sign = -1;
        }

        return Math.abs(roi - 1) * sign;
      }

      private Integer[] glue(Integer[] arr1, Integer[] arr2) {
        Integer[] res = new Integer[arr1.length + arr2.length];
        for (int i = 0; i < arr1.length; i++) {
          res[i] = arr1[i];
        }
        for (int i = 0; i < arr2.length; i++) {
          res[i + arr1.length] = arr2[i];
        }
        return res;
      }

      private int mod(int[] hist) {
        int resDirection = -1;
        int maxVal = -1;
        for (int i = 0; i < hist.length; i++) {
          if (hist[i] > maxVal) {
            resDirection = i;
            maxVal = hist[i];
          }
        }
        return resDirection;
      }

      private double roInverse(int[] forwardHist, int[] backwardHist) {

        double meanForward = mean(forwardHist);
        double meanBackward = mean(backwardHist);

        double up = 0.;
        double lowLeft = 0.;
        double lowRight = 0.;

        for (int i = 0; i < 8; i++) {
          up = up + (forwardHist[i] - meanForward) * (backwardHist[i] - meanBackward);
          lowLeft = lowLeft + (forwardHist[i] - meanForward) * (forwardHist[i] - meanForward);
          lowRight = lowRight + (backwardHist[i] - meanBackward) * (backwardHist[i] - meanBackward);
        }

        return up / Math.sqrt(lowLeft * lowRight);
      }

      private double mean(int[] forwardHist) {
        double res = 0.;
        for (int i = 0; i < forwardHist.length; i++) {
          res = res + (double) forwardHist[i];
        }
        return res / (double) forwardHist.length;
      }

      private int[] histogram(Integer[] array) {
        int[] res = new int[8];
        for (int i = 0; i < array.length; i++) {
          res[array[i]]++;
        }
        return res;
      }
    });
    // cream panoul pentru buton, ca sa nu ocupe toata zona
    JPanel panou = new JPanel();
    panou.setSize(200, 200);
    panou.setAlignmentY(50);
    panou.add(but);
    // incepem sa descriem constrangerile
    GridBagConstraints c = new GridBagConstraints();
    // primu vine butonul, care ocupa o celula
    c.gridx = 0;
    c.gridy = 0;
    c.gridwidth = 1;
    grid.setConstraints(panou, c);
    // apoi vine canvasul care ocupa 2 celule
    c.gridx = 1;
    c.gridwidth = 2;
    grid.setConstraints(canvas, c);
    add(panou);
    add(canvas);

    validate();

  }

  private int sum(int[] t) {
    int res = 0;
    for (int i = 0; i < t.length; i++) {
      res = res + t[i];
    }
    return res;
  }

  /** ne deplasam prin matrice in jurul punctului p, incepand de la punctul prev */
  private int deplasare(Point p, Point prev) {
    int t[] = new int[8];
    int start = 0, i = 0;
    if (p.x == 0 && p.y != 0 && p.y != 27) {
      t[0] = t[6] = t[7] = 0;
      t[1] = canvas.m1[p.x][p.y - 1];
      t[2] = canvas.m1[p.x + 1][p.y - 1];
      t[3] = canvas.m1[p.x + 1][p.y];
      t[4] = canvas.m1[p.x + 1][p.y + 1];
      t[5] = canvas.m1[p.x][p.y + 1];
    }
    else if (p.x == 27 && p.y != 0 && p.y != 27) {
      t[2] = t[3] = t[4] = 0;
      t[0] = canvas.m1[p.x - 1][p.y - 1];
      t[1] = canvas.m1[p.x][p.y - 1];
      t[5] = canvas.m1[p.x][p.y + 1];
      t[6] = canvas.m1[p.x - 1][p.y + 1];
      t[7] = canvas.m1[p.x - 1][p.y];
    }
    else if (p.y == 0 && p.x != 0 && p.x != 27) {
      t[0] = t[1] = t[2] = 0;
      t[3] = canvas.m1[p.x + 1][p.y];
      t[4] = canvas.m1[p.x + 1][p.y + 1];
      t[5] = canvas.m1[p.x][p.y + 1];
      t[6] = canvas.m1[p.x - 1][p.y + 1];
      t[7] = canvas.m1[p.x - 1][p.y];
    }
    else if (p.y == 27 && p.x != 0 && p.x != 27) {
      t[6] = t[5] = t[4] = 0;
      t[0] = canvas.m1[p.x - 1][p.y - 1];
      t[1] = canvas.m1[p.x][p.y - 1];
      t[2] = canvas.m1[p.x + 1][p.y - 1];
      t[3] = canvas.m1[p.x + 1][p.y];
      t[7] = canvas.m1[p.x - 1][p.y];
    }
    else if (p.x == 0 && p.y == 0) {
      t[0] = t[6] = t[7] = t[2] = t[1] = 0;
      t[3] = canvas.m1[p.x + 1][p.y];
      t[4] = canvas.m1[p.x + 1][p.y + 1];
      t[5] = canvas.m1[p.x][p.y + 1];
    }
    else if (p.x == 0 && p.y == 27) {
      t[0] = t[6] = t[7] = t[5] = t[4] = 0;
      t[1] = canvas.m1[p.x][p.y - 1];
      t[2] = canvas.m1[p.x + 1][p.y - 1];
      t[3] = canvas.m1[p.x + 1][p.y];
    }
    else if (p.x == 27 && p.y == 0) {
      t[0] = t[1] = t[2] = t[3] = t[4] = 0;
      t[5] = canvas.m1[p.x][p.y + 1];
      t[6] = canvas.m1[p.x - 1][p.y + 1];
      t[7] = canvas.m1[p.x - 1][p.y];
    }
    else if (p.x == 27 && p.y == 27) {
      t[6] = t[5] = t[4] = t[2] = t[3] = 0;
      t[0] = canvas.m1[p.x - 1][p.y - 1];
      t[1] = canvas.m1[p.x][p.y - 1];
      t[7] = canvas.m1[p.x - 1][p.y];
    }
    else {
      t[0] = canvas.m1[p.x - 1][p.y - 1];
      t[1] = canvas.m1[p.x][p.y - 1];
      t[2] = canvas.m1[p.x + 1][p.y - 1];
      t[3] = canvas.m1[p.x + 1][p.y];
      t[4] = canvas.m1[p.x + 1][p.y + 1];
      t[5] = canvas.m1[p.x][p.y + 1];
      t[6] = canvas.m1[p.x - 1][p.y + 1];
      t[7] = canvas.m1[p.x - 1][p.y];
    }
    if (prev.x == p.x - 1 && prev.y == p.y - 1)
      start = 0;
    if (prev.x == p.x && prev.y == p.y - 1)
      start = 1;
    if (prev.x == p.x + 1 && prev.y == p.y - 1)
      start = 2;
    if (prev.x == p.x + 1 && prev.y == p.y)
      start = 3;
    if (prev.x == p.x + 1 && prev.y == p.y + 1)
      start = 4;
    if (prev.x == p.x && prev.y == p.y + 1)
      start = 5;
    if (prev.x == p.x - 1 && prev.y == p.y + 1)
      start = 6;
    if (prev.x == p.x - 1 && prev.y == p.y)
      start = 7;
    for (i = start + 1; i < 8; i++) {
      if (t[i] == 1)
        break;
    }
    if (i == 8)
      for (i = 0; i <= start; i++)
        if (t[i] == 1)
          break;
    /*
     * prev.x=p.x; prev.y=p.y;
     */
    if (i == 0) {
      prev.x = p.x - 1;
      prev.y = p.y;
      p.x = p.x - 1;
      p.y = p.y - 1;
    }
    if (i == 1) {
      prev.x = p.x - 1;
      prev.y = p.y - 1;
      p.x = p.x;
      p.y = p.y - 1;
    }
    if (i == 2) {
      prev.x = p.x;
      prev.y = p.y - 1;
      p.x = p.x + 1;
      p.y = p.y - 1;
    }
    if (i == 3) {
      prev.x = p.x + 1;
      prev.y = p.y - 1;
      p.x = p.x + 1;
      p.y = p.y;
    }
    if (i == 4) {
      prev.x = p.x + 1;
      prev.y = p.y;
      p.x = p.x + 1;
      p.y = p.y + 1;
    }
    if (i == 5) {
      prev.x = p.x + 1;
      prev.y = p.y + 1;
      p.x = p.x;
      p.y = p.y + 1;
    }
    if (i == 6) {
      prev.x = p.x;
      prev.y = p.y + 1;
      p.x = p.x - 1;
      p.y = p.y + 1;
    }
    if (i == 7) {
      prev.x = p.x - 1;
      prev.y = p.y + 1;
      p.x = p.x - 1;
      p.y = p.y;
    }
    return i;
  }

  /** algoritmul MooreNeighbor */
  public Integer[] algoritm() {
    boolean solutionFound = false;
    int solutionCounter = 0;
    ArrayList<Integer> chainCode = new ArrayList<Integer>(); // resulting chain code
    do {
      Point start = new Point();// punctul de inceput
      Point prev_start = new Point();// punctul de inceput
      Point prev = new Point();
      Point p = new Point();// punctul curent
      int orientare = 0;// {0,1,2,3} cu 0 -in sus;1-la dreapta, etc..
      int i, j, dati = 0;
      // golim matricea a doua
      canvas.golire(2);
      // gasesc punctul de inceput
      chainCode = new ArrayList<Integer>(); // resulting chain code
      for (i = 0; i < 28; i++) {
        for (j = 27; j >= 0; j--)
          if (canvas.m1[i][j] == 1) {
            prev_start.x = prev.x = i;
            prev_start.y = prev.y = j + 1;
            start.x = p.x = i;
            start.y = p.y = j;
            System.out.println(p.x + " " + p.y + "\t" + prev.x + " " + prev.y);
            canvas.m2[i][j] = 1;
            canvas.repaint();
            break;
          }
        if (j >= 0)
          break;
      }
      /** cautam marginea desenului pana nu am ajuns in punctul de start din acelasi predecesor */

      int codeCounter = 0;
      do {

        int direction = deplasare(p, prev);
        chainCode.add(direction);

        System.out.println(p.x + " " + p.y + "\t" + prev.x + " " + prev.y);

        if (p.x == 6 && p.y == 20) {
          System.out.println("gotcha");
        }

        canvas.m2[p.x][p.y] = 1;
        Thread fir = new Thread(canvas);
        fir.start();
        try {
          Thread.sleep(100);
        }
        catch (InterruptedException e) {
          System.out.println("eroare");
        }
        codeCounter++;

        if (codeCounter > RUN_THRESHOLD) {
          break;
        }

        if ((p.x == start.x && p.y == start.y)
            && (prev.x != prev_start.x || prev.y != prev_start.y) && direction == 6) {
          prev.x = p.x;
          prev.y = p.y + 1;
        }
      }
      while (p.x != start.x || p.y != start.y || prev.x != prev_start.x || prev.y != prev_start.y);

      solutionFound = true;
      if (codeCounter > RUN_THRESHOLD) {
        solutionFound = false;
        solutionCounter++;

        canvas.m1 = rotate(canvas.m1);
        canvas.golire(2);
        canvas.repaint();

      }

      if (solutionCounter > 3) {
        System.out.println("bummer!");
      }

    }
    while (!(solutionFound));
    /*
     * lista1.clear(); lista2.clear();
     */
    System.out.println("exit");
    Integer[] chain = chainCode.toArray(new Integer[chainCode.size()]);
    return chain;

  }

  private int[][] rotate(int[][] mat) {
    int n = mat.length;
    int m = mat[0].length;
    int transpose[][] = new int[n][m];
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < m; j++) {
        transpose[i][j] = mat[j][m - i - 1];
      }
    }
    return transpose;
  }

}