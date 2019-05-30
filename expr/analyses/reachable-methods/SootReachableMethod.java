import java.util.Map;
import java.util.Iterator;
import java.io.IOException;
import java.io.BufferedWriter;
import java.io.FileWriter;

import soot.Main;
import soot.PackManager;
import soot.Transform;
import soot.SceneTransformer;

public class SootReachableMethod {
  public static void main(String[] args) {
    PackManager.v().getPack("wjtp").add(new Transform("wjtp.reachable-methods", new SceneTransformer() {
      protected void internalTransform(String phase, Map<String, String> options) {
        try { 
          String fileName = options.getOrDefault("output", "reachable-methods.txt");
          BufferedWriter writer = new BufferedWriter(new FileWriter(fileName));
          Iterator x = soot.Scene.v().getReachableMethods().listener();
          while (x.hasNext()) { 
            writer.write(x.next().toString());
            writer.write("\n");
          }
          writer.close();
        } catch (IOException e) { 
          e.printStackTrace();
        }
      }}));
    soot.Main.main(args);
  }
}
