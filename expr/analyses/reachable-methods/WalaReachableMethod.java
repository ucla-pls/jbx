import java.io.FileWriter;  

import java.io.File;
import java.io.IOException;
import java.util.Collection;
import java.util.Iterator;
import java.util.Properties;

import com.ibm.wala.ipa.callgraph.AnalysisCacheImpl;
import com.ibm.wala.ipa.callgraph.AnalysisOptions;
import com.ibm.wala.ipa.callgraph.AnalysisScope;
import com.ibm.wala.ipa.callgraph.CGNode;
import com.ibm.wala.ipa.callgraph.CallGraph;
import com.ibm.wala.ipa.callgraph.CallGraphBuilder;
import com.ibm.wala.ipa.callgraph.CallGraphStats;
import com.ibm.wala.ipa.callgraph.Entrypoint;
import com.ibm.wala.ipa.callgraph.impl.Util;
import com.ibm.wala.ipa.cha.ClassHierarchy;
import com.ibm.wala.ipa.cha.ClassHierarchyFactory;

import com.ibm.wala.classLoader.IClass;
import com.ibm.wala.classLoader.IMethod;
import com.ibm.wala.classLoader.Language;
import com.ibm.wala.types.TypeName;
import com.ibm.wala.types.Selector;
import com.ibm.wala.util.CancelException;
import com.ibm.wala.util.WalaException;
import com.ibm.wala.util.config.AnalysisScopeReader;
import com.ibm.wala.util.io.CommandLine;

public class WalaReachableMethod {
  
  public static void main(String[] args) throws WalaException, IllegalArgumentException, CancelException, IOException {
    Properties p = CommandLine.parse(args);
    String classpath = p.getProperty("classpath");
    String mainclass = p.getProperty("mainclass");
    String exclude = p.getProperty("exclude");
   
    System.out.println("Classpath " + classpath + " mainclass " + mainclass);
    System.out.println("Finding Scope");
    AnalysisScope scope = AnalysisScopeReader.makeJavaBinaryAnalysisScope(classpath, new File(exclude));
    ClassHierarchy cha = ClassHierarchyFactory.make(scope);

    System.out.println("Finding Entrypoints");
    Iterable<Entrypoint> entrypoints = Util.makeMainEntrypoints(scope, cha, "L" + mainclass.replaceAll("\\.","/"));
    // Iterable<Entrypoint> entrypoints = Util.makeMainEntrypoints(scope, cha);
    AnalysisOptions options = new AnalysisOptions(scope, entrypoints);

    System.out.println("Making ZeroCFA");
    CallGraphBuilder builder = Util.makeZeroCFABuilder(Language.JAVA, options, new AnalysisCacheImpl(), cha, scope);
    
    System.out.println("Building CallGraph");
    CallGraph g = builder.makeCallGraph(options, null);

    System.out.println("Printing results");
    FileWriter fw = new FileWriter("reachable-methods.txt");          
    for(Iterator<CGNode> it = g.iterator(); it.hasNext(); ) {
        CGNode item = it.next();
        IMethod m = item.getMethod();
        TypeName t = m.getDeclaringClass().getName();
        Selector sel = m.getSelector();
        String name = sel.getName().toString();
        if (name.startsWith("<"))
        {
            name = "\"" + name + "\"";
        }
        fw.write("" + t.getPackage() + "/" + t.getClassName() + "." + name + ":" + sel.getDescriptor() + "\n");
    }
    fw.close();    
  }
}
