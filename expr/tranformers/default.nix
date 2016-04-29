# This folder contains tranformators
{ utils, randoop, unzip }:
{
  randoop = 
    utils.mkTransformer 
      { name = "randoop";
        transform = benchmark: {
          mainclass = "org.junit.runner.JUnitCore";
          libraries = java: 
            with java.libs; (benchmark.libraries java) ++ [ hamcrest-core junit];
          build = java: 
            let b = benchmark.withJava java;
            in { 
              src = b.build;
              buildInputs = [ java.jdk randoop unzip] ++ b.libraries;
              buildPhase = ''
                find $src/share/java/ -name '*.jar' -exec unzip -n {} -d stuff \;
                export CLASSPATH="$CLASSPATH:stuff"
                ls -l stuff/*
                find stuff -name "*.class" | \
                  sed -e 's/stuff\///' -e 's/\.class//' -e 's/\//./g' -e 's/\$.*$//'\
                  > classes.txt
                java randoop.main.Main gentests --classlist=classes.txt --timelimit=60
                javac *.java
                mv *.class stuff
                cd stuff; jar vcf randoop-tests.jar .
              '';
              installPhase = ''
                mkdir -p $out/share/java
                mv randoop-tests.jar $_
                cd ..
                mv *.java $out
                mv classes.txt "$out"
              '';
            };
          inputs = [
            {
              name = "regression"; 
              args = [
                "RegressionTest"
              ];
            }
            { 
              name = "error";
              args = [ 
                "ErrorTest" 
              ];
            }
          ];
        };
      };
}
