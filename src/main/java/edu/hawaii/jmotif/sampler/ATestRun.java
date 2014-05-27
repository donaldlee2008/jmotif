package edu.hawaii.jmotif.sampler;

import java.util.logging.ConsoleHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Logger;
import org.hackystat.utilities.logger.HackystatLogger;
import edu.hawaii.jmotif.util.BriefFormatter;

public class ATestRun {

  private static double p[] = { 35.0, 5., 2. };
  private static Logger consoleLogger;

  // static bloc to init logger
  //
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

  /**
   * @param args
   * @throws Exception
   */
  public static void main(String[] args) throws Exception {

    // ObjectiveFunction cbfFunction = new UCRSyntheticFunction();
    //
    // PrintConsumer consumer = new PrintConsumer();
    //
    // DirectMethod method = new DirectMethod();
    // method.addConsumer(consumer);
    //
    // Solver solver = new BasicSolver(50);
    // solver.init(cbfFunction, method);
    // solver.addSystemStopCondition(condition)
    //
    // solver.solve();
  }

}
