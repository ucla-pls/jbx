import java.io.FileWriter;  
import java.io.File;
import java.io.IOException;
import java.util.Collection;
import java.util.Iterator;
import java.util.Properties;

import com.ibm.wala.ipa.callgraph.*;
import com.ibm.wala.ipa.callgraph.impl.Util;
import com.ibm.wala.ipa.cha.ClassHierarchy;
import com.ibm.wala.ipa.cha.ClassHierarchyFactory;

import com.ibm.wala.classLoader.*;
import com.ibm.wala.types.*;
import com.ibm.wala.util.*;
import com.ibm.wala.util.config.AnalysisScopeReader;
import com.ibm.wala.util.io.CommandLine;

public class WalaReachableMethod {
  
  public static void main(String[] args) throws WalaException, IllegalArgumentException, CancelException, IOException {
    Properties p = CommandLine.parse(args);
    String classpath = p.getProperty("classpath");
    String mainclass = p.getProperty("mainclass");
    String exclude = p.getProperty("exclude");
   
    AnalysisScope scope = AnalysisScopeReader.makeJavaBinaryAnalysisScope(classpath, new File(exclude));
    ClassHierarchy cha = ClassHierarchyFactory.make(scope);

    Iterable<Entrypoint> entrypoints = Util.makeMainEntrypoints(scope, cha, "L" + mainclass.replaceAll("\\.","/"));
    AnalysisOptions options = new AnalysisOptions(scope, entrypoints);
    options.setReflectionOptions(AnalysisOptions.ReflectionOptions.NONE);
    
    CallGraphBuilder builder = Util.makeZeroCFABuilder(Language.JAVA, options, new AnalysisCacheImpl(), cha, scope);
    CallGraph g = builder.makeCallGraph(options, null);

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
	
        fw.write("" + ( t.getPackage() == null ? "" : t.getPackage() + "/" ) + t.getClassName() + "." + name + ":" + sel.getDescriptor() + "\n");
    }
    fw.close();    
  }
}
