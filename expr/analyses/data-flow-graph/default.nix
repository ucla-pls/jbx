{utils, graphgen, jdk8, unzip, shared }:
{
  graphgen = utils.mkAnalysis {
    name = "graphgen";
    tools = [ jdk8 unzip ];
    analysis = ''
      mkdir graphs
      
      # Let's extract all jars and jar them in one jar!
      mkdir tmp
      cd tmp
      
      for jar in $(echo $classpath | tr ":" "\n")
      do
        unzip -o $jar 
      done

      rm -r META-INF

      jar vcf ../test.jar .

      # If the source path exists, add the sources to a file.
      if [[ -e "$srcpath" ]]
      then
        find "$srcpath" -name "*.java" >> sources.txt
      else
        touch sources.txt
      fi
     
      cd ..
    
      analyse "make-dot" java -jar ${graphgen}/share/java/prog2dfg.jar -o graphs -j test.jar -source sources.txt
    '';
    postprocess = ''
      cp -r sandbox/graphs .
    '';
  };
}
