import petablox.analyses.alias.CICGAnalysis;
import petablox.analyses.alias.ICICG;
import petablox.project.ClassicProject;
import petablox.project.ITask;
import petablox.project.OutDirUtils;
import petablox.project.Petablox;
import petablox.project.analyses.JavaAnalysis;
import petablox.util.ArraySet;
import petablox.util.soot.SootUtilities;
import soot.*;
import soot.jimple.Stmt;

import java.io.IOException;
import java.io.PrintWriter;

@Petablox(name="petablox-cg-java")
public class PetabloxCallgraph extends JavaAnalysis {

    private ITask cipa;
    private ICICG cicg;

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
        // Using 0-cfa as call graph analysis algorithm
        cipa = ClassicProject.g().getTask("cipa-0cfa-dlog");
        ClassicProject.g().runTask(cipa);
        CICGAnalysis cicgAnalysis = (CICGAnalysis) ClassicProject.g().getTask("cicg-java");
        ClassicProject.g().runTask(cicgAnalysis);
        cicg = cicgAnalysis.getCallGraph();

        try {

            PrintWriter writer = OutDirUtils.newPrintWriter("edges.txt");

            for (SootMethod callee : cicg.getNodes()) {
                ArraySet<Unit> invokes = cicg.getCallersOrdered(callee);
                for (Unit unit : invokes) {
                    Stmt stmt = (Stmt) unit;
                    SootMethod caller = SootUtilities.getMethod(unit);
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