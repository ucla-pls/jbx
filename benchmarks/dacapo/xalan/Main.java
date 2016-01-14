
import java.io.File;
import org.dacapo.xalan.XSLTBench;

public class Main {
    public static void main(String[] args) throws Exception {
        String scratch = args[0], threads = args[1], size = args[2];
        XSLTBench bench = new XSLTBench(new File(scratch));
        
        bench.createWorkers(Integer.parseInt(threads));
        bench.doWork(Integer.parseInt(size));
    }
}
