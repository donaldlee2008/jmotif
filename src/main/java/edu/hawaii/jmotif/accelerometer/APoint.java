package edu.hawaii.jmotif.accelerometer;

public class APoint {

  long ts;
  double x;
  double y;
  double z;

  public APoint(String line) {
    String[] split = line.split(",");
    this.ts = Double.valueOf(split[0]).longValue();
    this.x = Double.valueOf(split[1]);
    this.y = Double.valueOf(split[2]);
    this.z = Double.valueOf(split[3]);
  }

  public long getTs() {
    return ts;
  }

  public void setTs(long ts) {
    this.ts = ts;
  }

  public double getX() {
    return x;
  }

  public void setX(double x) {
    this.x = x;
  }

  public double getY() {
    return y;
  }

  public void setY(double y) {
    this.y = y;
  }

  public double getZ() {
    return z;
  }

  public void setZ(double z) {
    this.z = z;
  }

  @Override
  public String toString() {
    return "APoint [ts=" + ts + ", x=" + x + ", y=" + y + ", z=" + z + "]";
  }

  public String toFileLine() {
    return ts + "," + x + "," + y + "," + z;
  }

  public double distanceTo(APoint aPoint) {
    return Math.sqrt(  
        (this.x-aPoint.getX()) * (this.x-aPoint.getX()) +
        (this.x-aPoint.getY()) * (this.x-aPoint.getY()) +
        (this.x-aPoint.getZ()) * (this.x-aPoint.getZ()));
  }

}
