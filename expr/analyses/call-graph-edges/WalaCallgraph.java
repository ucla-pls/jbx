package walaOptions;


import java.io.FileWriter;  
import java.io.File;
import java.io.IOException;
import java.util.Collection;
import java.util.Iterator;
import java.util.Properties;
import java.util.Set;

import com.ibm.wala.ipa.callgraph.*;
import com.ibm.wala.ipa.callgraph.impl.Util;
import com.ibm.wala.ipa.cha.ClassHierarchy;
import com.ibm.wala.ipa.cha.ClassHierarchyFactory;

import com.ibm.wala.classLoader.*;
import com.ibm.wala.types.*;
import com.ibm.wala.util.*;
import com.ibm.wala.util.config.AnalysisScopeReader;
import com.ibm.wala.util.io.CommandLine;

public class WalaCallgraph {
  
  public static void main(String[] args) throws WalaException, IllegalArgumentException, CancelException, IOException {
    Properties p = CommandLine.parse(args);
    String classpath = p.getProperty("classpath");
    String mainclass = p.getProperty("mainclass");
    String outputfile = p.getProperty("output");
    String exclude = p.getProperty("exclude");
    String analysis = p.getProperty("analysis");
    String reflection = p.getProperty("reflection"); 
    String resolveinterfaces = p.getProperty("resolveinterfaces");
    //resolveinterfaces = false results in an analysis which does not resolve an interface edge to its actual possible targets

    AnalysisScope scope = AnalysisScopeReader.makeJavaBinaryAnalysisScope(classpath, null);
    ClassHierarchy cha = ClassHierarchyFactory.make(scope);

    Iterable<Entrypoint> entrypoints = Util.makeMainEntrypoints(scope, cha, "L" + mainclass.replaceAll("\\.","/"));
    AnalysisOptions options = new AnalysisOptions(scope, entrypoints);

    /* Choose the correct reflection option */
    if (reflection.equalsIgnoreCase("true")){
        options.setReflectionOptions(AnalysisOptions.ReflectionOptions.NO_FLOW_TO_CASTS_APPLICATION_GET_METHOD);
    } else {
        options.setReflectionOptions(AnalysisOptions.ReflectionOptions.NONE);
    }
    
    /* Choose the correct analysis option */
    CallGraphBuilder builder;
    switch(analysis) {
        case "0cfa":
            builder = Util.makeZeroCFABuilder(Language.JAVA, options, new AnalysisCacheImpl(), cha, scope);
            break;
        case "1cfa":
            builder = Util.makeNCFABuilder(1, options, new AnalysisCacheImpl(), cha, scope);
            break;
        case "rta":
            builder = Util.makeRTABuilder(options, new AnalysisCacheImpl(), cha, scope);
            break;
        default:
            System.out.println("-----Invalid analysis option----");
            builder = null;
    }
    
    CallGraph graph = builder.makeCallGraph(options, null);

    File file = new File(outputfile);    
    file.createNewFile();
    FileWriter fw = new FileWriter(file);
    fw.write("method,offset,target\n"); //Header line
             
    for(Iterator<CGNode> it = graph.iterator(); it.hasNext(); ) {
        CGNode cgnode = it.next();
        IMethod m1 = cgnode.getMethod();
        TypeName t1 = m1.getDeclaringClass().getName();
        Selector sel1 = m1.getSelector();
        String name1 = sel1.getName().toString();
        String firstMethod = "" + ( t1.getPackage() == null ? "" : t1.getPackage() + "/" ) + t1.getClassName() + "." + name1 + ":" + sel1.getDescriptor();

        boolean bootSrcMethod = (firstMethod.equals("com/ibm/wala/FakeRootClass.fakeRootMethod:()V") 
                        || firstMethod.equals("com/ibm/wala/FakeRootClass.fakeWorldClinit:()V"));

        for(Iterator<CallSiteReference> it2 =  cgnode.iterateCallSites(); it2.hasNext(); ) {
            CallSiteReference csref = it2.next();
            /* Choose to resolve the interface edge or not based on the input */
            if (resolveinterfaces.equalsIgnoreCase("true")){
                Set<CGNode> possibleActualTargets = graph.getPossibleTargets(cgnode,csref);
                for (CGNode cgnode2 : possibleActualTargets){
                    IMethod m2 = cgnode2.getMethod();
                    TypeName t2 = m2.getDeclaringClass().getName();
                    Selector sel2 = m2.getSelector();
                    String name2 = sel2.getName().toString();
                    String secondMethod = "" + ( t2.getPackage() == null ? "" : t2.getPackage() + "/" ) + t2.getClassName() + "." + name2 + ":" + sel2.getDescriptor() + "\n";
                        
                    int bytecodeOffset;
                    //Decide the bytecode offset (and fix firstMethod) depending on if it is a boot method
                    if (bootSrcMethod){
			        	firstMethod = "<boot>";
			        	bytecodeOffset = 0;
			        } else {
			        	bytecodeOffset = csref.getProgramCounter();
			        }

                    //Rename destination node if it is a boot method
                    if (secondMethod.equals("com/ibm/wala/FakeRootClass.fakeWorldClinit:()V\n")){
                        secondMethod = "<boot>\n";
                    }
                    fw.write(firstMethod + "," + bytecodeOffset + "," + secondMethod); 
                }           
            } else {
                MethodReference m2 = csref.getDeclaredTarget();
                TypeName t2 = m2.getDeclaringClass().getName();
                Selector sel2 = m2.getSelector();
                String name2 = sel2.getName().toString();
                String secondMethod = "" + ( t2.getPackage() == null ? "" : t2.getPackage() + "/" ) + t2.getClassName() + "." + name2 + ":" + sel2.getDescriptor() + "\n";
                
                int bytecodeOffset;
                //Decide the bytecode offset (and fix firstMethod) depending on if it is a boot method
                if (bootSrcMethod){
                    firstMethod = "<boot>";
                    bytecodeOffset = 0;
                } else {
                    bytecodeOffset = csref.getProgramCounter();
                }
                
                //Rename destination node if it is a boot method
                if (secondMethod.equals("com/ibm/wala/FakeRootClass.fakeWorldClinit:()V\n")){
                    secondMethod = "<boot>\n";
                }

                fw.write(firstMethod + "," + bytecodeOffset + "," + secondMethod);
            }
        }
        
        /* I think new() sites are already included in call site references */
        /*
        for(Iterator<NewSiteReference> it3 =  cgnode.iterateNewSites(); it3.hasNext(); ) {
            NewSiteReference = it3.next()

            Set<CGNode> possibleTargets = graph.getPossibleTargets(cgnode,csref);
            for (CGNode cgnode2 : getNodes()){

            }
        }
        */
    }
    fw.close();  
  }
}