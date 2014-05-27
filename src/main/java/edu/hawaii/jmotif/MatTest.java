package edu.hawaii.jmotif;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays;
import java.util.Map;
import com.jmatio.io.MatFileReader;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLDouble;

public class MatTest {

  /**
   * @param args
   * @throws IOException
   * @throws FileNotFoundException
   */
  public static void main(String[] args) throws FileNotFoundException, IOException {
    MatFileReader mfr = new MatFileReader("synemp-test.mat");
    Map<String, MLArray> mlArrayRetrived = mfr.getContent();

    MLArray dy = mlArrayRetrived.get("Y");
    MLArray dx = mlArrayRetrived.get("X");

    BufferedWriter bw = new BufferedWriter(new FileWriter(new File("synemp-test.txt")));
    double[] arr = ((MLDouble) dy).getArray()[0];
    bw.write(Arrays.toString(arr).replace(",", " ").replace("[", "").replace("]", "\n"));

    for (int i = 0; i < dx.getM(); i++) {
      arr = ((MLDouble) dx).getArray()[i];
      bw.write(Arrays.toString(arr).replace(",", " ").replace("[", "").replace("]", "\n"));
      System.out.println(i);
    }
    bw.close();

  }

}
