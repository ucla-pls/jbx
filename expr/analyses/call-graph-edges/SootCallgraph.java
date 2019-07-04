import soot.*;
import soot.jimple.*;
import soot.jimple.spark.SparkTransformer;
import soot.jimple.toolkits.callgraph.CHATransformer;
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
    writer.write(method.toString().replaceAll("\'",""));
    writer.write(";");
    writer.write(Integer.toString(counter));
    writer.write(";");
    writer.write(e != null ? e.toString().replaceAll("\'","") : "null");
    writer.write(";");
    SootMethodRef ref = stmt.getInvokeExpr().getMethodRef();
    writer.write(ref.declaringClass().getName());
    writer.write(".");
    writer.write(ref.name());
    writer.write("\n");
  }

  private static int getOrder(SootMethod m, Unit instr){
        try {
            Body method_body = m.retrieveActiveBody();
            PatchingChain<Unit> chain = method_body.getUnits();
            int order = 0;
            for (Unit u : chain) {
                Stmt stmt = (Stmt) u;
                if (stmt.containsInvokeExpr()){
                    if (stmt == instr){
                        return order;
                    }
                    order+=1;
                }
            }
        } catch (Exception e){
            System.out.println(e.toString());
            return -1;
        }

        return -2;
  }

  // For debugging
  private void printIR (String methodSig) {
      SootMethod m = Scene.v().getMethod(methodSig);
      try {
          for(Unit u : m.retrieveActiveBody().getUnits()){
              System.out.println("[PRINT] " + u);
          }
      } catch (Exception e) {
        System.out.println("[ERROR] error encountered when trying to print. ");
      }
      System.out.println();
  }

  private void proccess(Chain<SootClass> app) throws IOException {

    CallGraph cg = Scene.v().getCallGraph();

    BufferedWriter writer = new BufferedWriter(new FileWriter(output));
    
    Iterator<MethodOrMethodContext> srcMethod_iterator = cg.sourceMethods();
    while (srcMethod_iterator.hasNext()){
        MethodOrMethodContext mmc = srcMethod_iterator.next();
        SootMethod source = mmc.method();
        if (source == null) continue;
        Iterator<Edge> edge_it = cg.edgesOutOf(mmc);
        while (edge_it.hasNext()) {
            Edge edge = edge_it.next();
            SootMethod target = edge.tgt();
            Stmt stmt = edge.srcStmt();
            int order = getOrder(source, stmt);
            if(order < 0) continue;

            if(source.getName().contains("printFooter") && target.getName().contains("println")) {
                System.out.println("[DEBUG] " + source.getSignature());
                System.out.println("[DEBUG] " + stmt.toString());
            }

            write(writer, source, order, target, stmt);
        }
    }

    writer.close();
  }

  private void callSpark(Map options){
    HashMap opt = new HashMap(options);
    opt.put("enabled","true");
    opt.put("verbose", "true");
    opt.put("on-fly-cg","true");
    opt.put("simple-edges-bidirectional", "false");
    opt.put("vta", "false");
    opt.put("rta", "false");
    opt.put("propagator","worklist");
    opt.put("ignore-types","false");
    opt.put("field-based","false");
    opt.put("pre-jimplify","false");
    opt.put("class-method-var","true");
    opt.put("dump-pag","false");
    opt.put("force-gc","true");
    opt.put("pre-jimplify","false");
    opt.put("merge-stringbuffer","false");
    opt.put("string-constants","false");
    opt.put("simulate-natives","true");
    opt.put("simplify-offline","false");
    opt.put("simplify-sccs","true");
    opt.put("ignore-types-for-sccs","false");
    opt.put("set-impl","double");
    opt.put("double-set-old","hybrid");
    opt.put("double-set-new","hybrid");
    opt.put("dump-html","false");
    opt.put("dump-pag","false");
    opt.put("dump-solution","false");
    opt.put("topo-sort","false");
    opt.put("dump-types","false");
    opt.put("dump-answer","false");
    opt.put("add-tags","false");
    opt.put("set-mass","false");
    opt.put("app-only","false");

    SparkTransformer.v().transform("", opt);
  }


  @Override
  protected void internalTransform(String phaseName, Map options) {
    Chain<SootClass> app = Scene.v().getClasses();

    try {proccess(app);} catch (IOException i) {}
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
    Options.v().set_no_bodies_for_excluded(true);
    
    SootClass entryClass = Scene.v().loadClassAndSupport(mainClass);
    Scene.v().loadNecessaryClasses();
    SootMethod entryMethod = entryClass.getMethodByName("main");
    
    SootMethod method = Scene.v().getMainMethod();
    List <SootMethod> entryPoints = new ArrayList<>();
    entryPoints.add(method);
    Scene.v().setEntryPoints(entryPoints);
    
    
    PackManager.v().getPack("wjtp").add(new Transform("wjtp.myTrans", new SootCallgraph(output)));
    soot.Main.main(newargs);
 }
}
