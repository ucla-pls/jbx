
import petablox.analyses.alias.CSCGAnalysis;
import petablox.analyses.alias.Ctxt;
import petablox.analyses.alias.ICSCG;
import petablox.project.ClassicProject;
import petablox.project.ITask;
import petablox.project.OutDirUtils;
import petablox.project.Petablox;
import petablox.project.analyses.JavaAnalysis;
import petablox.util.soot.SootUtilities;
import petablox.util.tuple.object.Pair;
import soot.*;
import soot.jimple.Stmt;

import java.io.IOException;
import java.io.PrintWriter;

@Petablox(name="petablox-cg-java")
public class PetabloxCallgraph extends JavaAnalysis {

    private ITask cspa;
    private ITask kcfa;
    private ITask argcopy;
    private ICSCG cscg;


    private static void write(
            PrintWriter writer, SootMethod src, int counter,
            SootMethod tgt, Stmt stmt) throws IOException {
        writer.print(src.toString());
        writer.print(";");
        writer.print(Integer.toString(counter));
        writer.print(";");
        writer.print(tgt != null ? tgt.toString() : "null");
        writer.print(";");
        SootMethodRef ref = stmt.getInvokeExpr().getMethodRef();
        writer.print(ref.declaringClass().getName());
        writer.print(".");
        writer.print(ref.name());
        writer.print("\n");
    }

    public void run() {
        // Context Sensitive Analysis
        cspa = ClassicProject.g().getTask("ctxts-java");
        ClassicProject.g().runTask(cspa);
        argcopy = ClassicProject.g().getTask("argCopy-dlog");
        ClassicProject.g().runTask(argcopy);
        kcfa = ClassicProject.g().getTask("cspa-kcfa-dlog");
        ClassicProject.g().runTask(kcfa);
        CSCGAnalysis cscgAnalysis = (CSCGAnalysis) ClassicProject.g().getTask("cscg-java");
        ClassicProject.g().runTask(cscgAnalysis);
        cscg = cscgAnalysis.getCallGraph();

        try {

            PrintWriter writer = OutDirUtils.newPrintWriter("edges.txt");

            for (Pair<Ctxt, SootMethod> pair : cscg.getNodes()) {
                Ctxt ctxt = pair.val0;
                SootMethod callee = pair.val1;
                for (Pair<Ctxt, Unit> ivk_pair:cscg.getCallers(ctxt, callee)) {
                    Stmt stmt = (Stmt) ivk_pair.val1;
                    SootMethod caller = SootUtilities.getMethod(ivk_pair.val1);
                    int counter = getOrder(caller, stmt);
                    write(writer, caller, counter, callee, stmt);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
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
}