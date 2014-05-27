package edu.hawaii.jmotif.sampler;

import java.util.ArrayList;
import java.util.TreeMap;
import java.util.logging.ConsoleHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Logger;
import org.hackystat.utilities.logger.HackystatLogger;
import edu.hawaii.jmotif.text.SAXCollectionStrategy;
import edu.hawaii.jmotif.util.BriefFormatter;

public class PrintConsumer implements Consumer<ValuePointListTelemetryColored> {

  private static final String COMMA = ",";
  private static Logger consoleLogger;

  static {
    consoleLogger = HackystatLogger.getLogger("debug.console", "preseries");
    consoleLogger.setUseParentHandlers(false);
    for (Handler handler : consoleLogger.getHandlers()) {
      consoleLogger.removeHandler(handler);
    }
    ConsoleHandler handler = new ConsoleHandler();
    Formatter formatter = new BriefFormatter();
    handler.setFormatter(formatter);
    consoleLogger.addHandler(handler);
    HackystatLogger.setLoggingLevel(consoleLogger, "ALL");
  }

  private String prefix;
  private int callNumber = -1;
  private ArrayList<TreeMap<String, Double>> points = new ArrayList<TreeMap<String, Double>>();

  public PrintConsumer(SAXCollectionStrategy strategy) {
    super();
    prefix = "NOREDUCTION";
    if (strategy.equals(SAXCollectionStrategy.CLASSIC)) {
      prefix = "CLASSIC";
    }
    else if (strategy.equals(SAXCollectionStrategy.EXACT)) {
      prefix = "EXACT";
    }
  }

  @Override
  public void notifyOf(Producer<? extends ValuePointListTelemetryColored> producer) {

    callNumber++;
    TreeMap<String, Double> cMap = new TreeMap<String, Double>();
    points.add(cMap);

    ValuePointListTelemetryColored val = producer.getValue();
    int size = val.getValue().size();
    for (int i = 0; i < size; i++) {
      double error = val.getValue().get(i).getValue();
      double[] coordinates = val.getValue().get(i).getPoint().toArray();
      String coordStr = prefix + COMMA + coordinates[0] + COMMA + coordinates[1] + COMMA
          + coordinates[2];
      cMap.put(coordStr, error);
      if (callNumber > 0) {
        if (!(points.get(callNumber - 1).containsKey(coordStr))) {
          consoleLogger.info(callNumber + COMMA + coordStr + COMMA + error);
        }
      }
      else {
        consoleLogger.info(callNumber + COMMA + coordStr + COMMA + error);
      }

    }

  }
}
