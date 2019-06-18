import soot.*;
import soot.jimple.*;
import soot.jimple.toolkits.callgraph.CallGraph;
import soot.jimple.toolkits.callgraph.Edge;
import soot.jimple.toolkits.callgraph.ReachableMethods;
import soot.util.Chain;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class SootCallgraph extends SceneTransformer {

  private final String output;
  public SootCallgraph(String output) {
    this.output = output;
  }

  private static void write(
      BufferedWriter writer, SootMethod method, int counter, 
      SootMethod e, Stmt stmt) throws IOException {
    writer.write(method.toString());
    writer.write(";");
    writer.write(Integer.toString(counter));
    writer.write(";");
    writer.write(e != null ? e.toString() : "null");
    writer.write(";");
    writer.write(stmt.getInvokeExpr().getMethodRef().toString());
    writer.write("\n");
  }

  private void proccess(Chain<SootClass> app) throws IOException {
    CallGraph cg = Scene.v().getCallGraph();
    ReachableMethods reachableMethods = Scene.v().getReachableMethods();
    BufferedWriter writer = new BufferedWriter(new FileWriter(output));

    for (SootClass sc : app) {
      List<SootMethod> methods = sc.getMethods();
      for (SootMethod method : methods) {
        if (!reachableMethods.contains(method)) continue;
        if (method.isPhantom() || method.isAbstract() || !method.hasActiveBody()) continue;

        // Extracting the code body of this method
        Body body = method.retrieveActiveBody();
        if (body == null) continue;
        // Initialize a counter for the order
        int counter = 0;
        // Cast to JimpleBody
        JimpleBody b = (JimpleBody) body;

        PatchingChain<Unit> chain = b.getUnits();
        for (Unit u : chain) {
          Stmt stmt = (Stmt) u;
          if(!stmt.containsInvokeExpr()) continue;
          Iterator<Edge> o = cg.edgesOutOf(method);
          boolean found = false;
          while (o.hasNext()) {
            Edge e = o.next();
            Stmt src_stmt = e.srcStmt();
            if (src_stmt == stmt) {
              write(writer, method, counter, e.tgt(), stmt);
              found = true;
            }
          }
          if (!found) {
            write(writer, method, counter, null, stmt);
          }
          counter += 1;
        }
      }
    }
    writer.close();
  }

  @Override
  protected void internalTransform(String phaseName, Map options) {
    Chain<SootClass> app = Scene.v().getClasses();
    try {
      proccess(app);
    } catch (IOException i) {

    }
  }
 
 public static void main(String[] args) {
   String output = args[0];
   String[] newargs = new String[args.length -1];
   for (int i = 1; i < args.length; i++) {
     newargs[i - 1] = args[i];
   }
   PackManager.v().getPack("wjtp").add(new Transform("wjtp.myTrans", new SootCallgraph(output)));
   soot.Main.main(newargs);
 }
}
