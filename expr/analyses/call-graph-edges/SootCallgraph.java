import soot.*;
import soot.jimple.*;
import soot.jimple.spark.SparkTransformer;
import soot.jimple.toolkits.callgraph.CallGraph;
import soot.jimple.toolkits.callgraph.Edge;
import soot.jimple.toolkits.callgraph.ReachableMethods;
import soot.util.Chain;
import soot.options.Options;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

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
    SootMethodRef ref = stmt.getInvokeExpr().getMethodRef();
    writer.write(ref.declaringClass().getName());
    writer.write(".");
    writer.write(ref.name());
    writer.write("\n");
  }

  private void proccess(Chain<SootClass> app) throws IOException {
    CallGraph cg = Scene.v().getCallGraph();
    ReachableMethods reachableMethods = Scene.v().getReachableMethods();
    BufferedWriter writer = new BufferedWriter(new FileWriter(output));


    for (SootClass sc : app) {
      List<SootMethod> methods = sc.getMethods();
      for (SootMethod method : methods) {
        if (!reachableMethods.contains(method)) {
            continue;
        }
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
          counter += 1;
        }
      }
    }
    writer.close();
  }

  @Override
  protected void internalTransform(String phaseName, Map options) {
    HashMap opt = new HashMap(options);
    opt.put("enabled","true");
    opt.put("verbose", "true");
    opt.put("on-fly-cg","true");
    opt.put("simple-edges-bidirectional", "false");
    opt.put("vta", "false");
    opt.put("rta", "false");
    opt.put("propagator","worklist");
    opt.put("force-gc","true");
    opt.put("ignore-types","false");
    opt.put("field-based","false");
    opt.put("pre-jimplify","false");
    opt.put("class-method-var","true");
    opt.put("dump-pag","false");

    SparkTransformer.v().transform("", opt);	  
    Chain<SootClass> app = Scene.v().getClasses();
    try {
      proccess(app);
    } catch (IOException i) {

    }
  }
 
 public static void main(String[] args) {
   String output = args[0];
   String[] newargs = new String[args.length -2];
   for (int i = 2; i < args.length; i++) {
     newargs[i - 2] = args[i];
   }
   
   // Adding a new cmd argument to specify the main class name
   // because we need to set ther entry point manually (soot would treat all methods 
   // in the main class as entry points if none is set)  
   String mainClass = args[1];
   Options.v().parse(newargs);
   SootClass c = Scene.v().forceResolve(mainClass, SootClass.BODIES);
   c.setApplicationClass();
   Scene.v().loadNecessaryClasses();
   SootMethod method = Scene.v().getMainMethod();
   List <SootMethod> entryPoints = new ArrayList<>();
   entryPoints.add(method);
   Scene.v().setEntryPoints(entryPoints);
   
   PackManager.v().getPack("wjtp").add(new Transform("wjtp.myTrans", new SootCallgraph(output)));
   soot.Main.main(newargs);
 }
}
