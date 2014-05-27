package edu.hawaii.jmotif.performance.digits;

/*
 * Matrice.java
 *
 * Created on 31 octombrie 2005, 17:53
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */
import java.awt.event.MouseEvent;
import javax.swing.event.MouseInputListener;

/**
 * 
 * @author Strainu
 */
public class Matrice implements MouseInputListener{
  CanvasMatrice canvas;
  int value;
  /** Creates a new instance of Matrice */
  public Matrice(CanvasMatrice c) {
      canvas=c;
  }
  public  void mouseClicked( MouseEvent e ){
      int x=e.getX(),y=e.getY();
      if(x>=20 && y>=20 && x<300 && y<300)
      {
          x=x/10-1;
          y=y/10-1;
          value=canvas.m1[x][y]=1-canvas.m1[x][y];
      }
      canvas.repaint();
  }
  public void mouseEntered( MouseEvent e ) {}
  public void mouseExited( MouseEvent e ) {}
  public void mousePressed( MouseEvent e ){}
  public void mouseReleased( MouseEvent e ) {}
  public void mouseDragged( MouseEvent e )  {
      int x=e.getX(),y=e.getY();
      if(x>=20 && y>=20 && x<300 && y<300)
      {
          x=x/10-1;
          y=y/10-1;
          canvas.m1[x][y]=value;
      }
      canvas.repaint();
  }
  public void mouseMoved( MouseEvent e )  {}
}