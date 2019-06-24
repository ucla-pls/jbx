
import petablox.analyses.alias.*;
import petablox.project.ClassicProject;
import petablox.project.ITask;
import petablox.project.OutDirUtils;
import petablox.project.Petablox;
import petablox.project.analyses.JavaAnalysis;
import petablox.util.ArraySet;
import petablox.util.soot.SootUtilities;
import petablox.util.tuple.object.Pair;
import soot.*;
import soot.jimple.Stmt;

import java.io.PrintWriter;

@Petablox(name="petablox-cg-java")
public class PetabloxCallgraph extends JavaAnalysis {

    // For Context Sensitive
    private ITask cspa;
    private ITask kcfa;
    private ITask argcopy;
    private ICSCG cscg;

    // For Context Insensitive
    private ITask cipa;
    private ICICG cicg;

    private static void write(
            PrintWriter writer, SootMethod src, int counter,
            SootMethod tgt, Stmt stmt) {

        writer.print(src.toString().replace("\'",""));
        writer.print(";");
        writer.print(Integer.toString(counter));
        writer.print(";");
        writer.print(tgt != null ? tgt.toString().replace("\'","") : "null");
        writer.print(";");
        SootMethodRef ref = stmt.getInvokeExpr().getMethodRef();
        writer.print(ref.declaringClass().getName());
        writer.print(".");
        writer.print(ref.name());
        writer.print("\n");
    }

    public void run() {

        int cs = Integer.getInteger("petablox.cs");
        String outfile = System.getProperty("petablox.outfile", "callgraph.txt");
        PrintWriter writer = OutDirUtils.newPrintWriter(outfile);

        if(cs == 0){
            // Context insensitive analysis
            cipa = ClassicProject.g().getTask("cipa-0cfa-dlog");
            ClassicProject.g().runTask(cipa);
            CICGAnalysis cicgAnalysis = (CICGAnalysis) ClassicProject.g().getTask("cicg-java");
            ClassicProject.g().runTask(cicgAnalysis);
            cicg = cicgAnalysis.getCallGraph();
            for (SootMethod callee : cicg.getNodes()) {

                ArraySet<Unit> invokes = cicg.getCallersOrdered(callee);
                for (Unit unit : invokes) {
                    Stmt stmt = (Stmt) unit;
                    SootMethod caller = SootUtilities.getMethod(unit);
					
					/// DEBUGGING ///
					if (caller.getDeclaringClass().getName().contains("FileTime")){
						System.out.println("#### " + caller.toString());
					}
					////////////////

                    int counter = getOrder(caller, stmt);
                    write(writer, caller, counter, callee, stmt);
                }
            }

        } else if (cs == 1){
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

        } else {
            System.err.println("Invalid petablox analysis flag (only 0 or 1 is valid)");
        }
	writer.close();
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
