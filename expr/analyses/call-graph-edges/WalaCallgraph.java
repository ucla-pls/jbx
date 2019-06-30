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
  
  //Lambda start string constants to identify lambda methods
  public static String walaLambdaStartString = "wala/lambda$";
  public static String lambdaMetafactoryStartString = "java/lang/invoke/LambdaMetafactory.";
  public static String lambdaMetafactoryClinit = "<clinit>:()V";
  public static String walaArrayCopy = "com/ibm/wala/model/java/lang/System.arraycopy:(Ljava/lang/Object;Ljava/lang/Object;)V";
  public static String javaLibArrayCopy = "java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V";
  
  //Reformat the method if it is a lambda. Else simply return it.
  public static String reformatIfLambda(String inputMethod){
  	String outputMethod;
  	if (inputMethod.startsWith(walaLambdaStartString)){
  		String fullLambdaSignature = inputMethod.substring(walaLambdaStartString.length()); //remove wala start string
  		String lambdaSignatureWithoutArgs = fullLambdaSignature.split(":")[0];
  		String classname = lambdaSignatureWithoutArgs.split("\\.")[0];
  		String classnameFormatted = classname.replaceAll("\\$","/");
  		String methodname = lambdaSignatureWithoutArgs.split("\\.")[1];
  		outputMethod = classnameFormatted + "<lambda/" + methodname + ">:()V";
  		return outputMethod;
  	}
  	else if (inputMethod.startsWith(lambdaMetafactoryStartString)){
  		String fullLambdaSignature = inputMethod.substring(lambdaMetafactoryStartString.length()); //remove lambdametafactor start string
  		if (fullLambdaSignature.equals(lambdaMetafactoryClinit)){
  			return inputMethod; //Don't want to do this for the Clinit function
  		}
  		String lambdaSignatureWithoutArgs = fullLambdaSignature.split(":")[0];
  		String methodname = (lambdaSignatureWithoutArgs.split("\\$"))[0];
  		String classname = lambdaSignatureWithoutArgs.substring(methodname.length()+1); //remove the method name and first $
  		String classnameFormatted = classname.replaceAll("\\$","/");
  		outputMethod = classnameFormatted + "<lambda/" + methodname + ">:()V";
  		return outputMethod;
  	}
  	else{ //If it is not a lambda method
  		return inputMethod;
  	}
  }

  //format the method to the required bytecode format
  public static String formatMethod(TypeName t,String methodname,Selector sel){
  	String qualifiedClassName = "" + ( t.getPackage() == null ? "" : t.getPackage() + "/" ) + t.getClassName();
  	String formattedMethod = qualifiedClassName + "." + methodname + ":" + sel.getDescriptor();
  	//Modify the method if it is a lambda
    formattedMethod = reformatIfLambda(formattedMethod);
    //If it is wala arrayCopy, replace with java Arraycopy
    if (formattedMethod.equals(walaArrayCopy)){
    	formattedMethod = javaLibArrayCopy;
    }
    return formattedMethod;
  }

  //formats the final output line
  public static String formatFinalOutput(String firstMethod,String secondMethod,boolean bootSrcMethod,int off){
  	//Decide the bytecode offset (and fix firstMethod) depending on if it is a boot method
	int bytecodeOffset;
	if (bootSrcMethod){
	    firstMethod = "<boot>";
	    bytecodeOffset = 0;
	} else {
	    bytecodeOffset = off;
	}

	//Skip this edge if  destination node is a boot method
	if (secondMethod.equals("com/ibm/wala/FakeRootClass.fakeWorldClinit:()V")){
	    return null;
	}
  	return firstMethod + "," + bytecodeOffset + "," + secondMethod + "\n";
  }

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
        String firstMethod = formatMethod(t1,name1,sel1);

        //Record if this is a fakeRoot/boot method or not
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
                    
                    String secondMethod = formatMethod(t2,name2,sel2); 
                    String formattedOutputLine =  formatFinalOutput(firstMethod,secondMethod,bootSrcMethod,csref.getProgramCounter());
                    if (formattedOutputLine!=null){
                    	fw.write(formattedOutputLine); 
                    }
                }           
            } else {
                MethodReference m2 = csref.getDeclaredTarget();
                TypeName t2 = m2.getDeclaringClass().getName();
                Selector sel2 = m2.getSelector();
                String name2 = sel2.getName().toString();
                
                String secondMethod = formatMethod(t2,name2,sel2);
                String formattedOutputLine =  formatFinalOutput(firstMethod,secondMethod,bootSrcMethod,csref.getProgramCounter());
                if (formattedOutputLine!=null){
                    	fw.write(formattedOutputLine); 
                }
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
