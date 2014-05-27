package edu.hawaii.jmotif.performance.digits;

import java.awt.Canvas;
import java.awt.Color;
import java.awt.Graphics;

public class CanvasMatrice extends Canvas implements Runnable{
  /**
   * 
   */
  private static final long serialVersionUID = 1L;
  public int m1[][]=new int[28][28];
  public int m2[][]=new int[28][28];
  /** Creates a new instance of CanvasMatrice */
  public CanvasMatrice() {
      for(int i=0;i<28;i++)
          for(int j=0;j<28;j++)
          {
              m1[i][j]=0;
              m1[i][j]=0;
          }
  }
  public void paint(Graphics g){
      g.clearRect(0,0, 400, 400);
      for(int i=1;i<=28;i++)
          for(int j=1;j<=28;j++)
          {
              //desenam matricea 1
              if(m1[i-1][j-1]==1)
              {
                  g.setColor(Color.BLUE);
                  g.fillRect(i*10,j*10,10,10);
              }
              else
              {
                  g.setColor(Color.LIGHT_GRAY);
                  g.drawRect(i*10,j*10,10,10);
              }
              //desenam matricea 2
              if(m2[i-1][j-1]==1){
                  g.setColor(Color.BLUE);
                  g.fillRect(i*10+300,j*10,10,10);
              }
              else
              {
                  g.setColor(Color.LIGHT_GRAY);
                  g.drawRect(i*10+300,j*10,10,10);
              }
          }
  }
  /**golim matricele m1,m2 sau ambele
   *Intrari: careMatrice=0-ambele/1-doar matricea 1/2-doar matricea 2
   *Iesiri: nimic*/
  void golire(int careMatrice){
      if(careMatrice==1|| careMatrice==0)
          for(int i=0;i<28;i++)
              for(int j=0;j<28;j++)
                  m1[i][j]=0;
      if(careMatrice==2|| careMatrice==0)
          for(int i=0;i<28;i++)
              for(int j=0;j<28;j++)
                  m2[i][j]=0;
  }
  public void run(){
      Graphics g=this.getGraphics();
      this.paint(g);
  }
}