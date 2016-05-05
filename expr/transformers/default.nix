# This folder contains tranformators
{ utils, randoop, unzip }:
{
  randoop = 
    utils.mkTransformer 
      { name = "randoop";
        transform = benchmark: {
          mainclass = "RegressionDriver";
          libraries = java: 
            with java.libs; (benchmark.libraries java) ++ [ hamcrest-core junit];
          build = java: 
            let 
              b = benchmark.withJava java;
              timelimit = 10;
              outputlimit = 100;
            in { 
              src = b.build;
              phases = "buildPhase installPhase";
              buildInputs = [ java.jdk randoop unzip] ++ b.libraries 
                ++ (with java.libs; [ hamcrest-core junit]);
              buildPhase = ''
                find $src/share/java/ -name '*.jar' -exec unzip -n {} -d stuff \;
                export CLASSPATH="$CLASSPATH:stuff"
                find stuff -name "*.class" | \
                  sed -e 's/stuff\///' -e 's/\.class//' -e 's/\//./g' -e 's/\$.*$//'\
                  | sort | uniq > classes.txt
                java -ea randoop.main.Main gentests \
                  --classlist=classes.txt \
                  --timelimit=${toString timelimit} \
                  --junit-reflection-allowed=false \
                  --outputlimit=${toString outputlimit} \
                  --silently-ignore-bad-class-names=true
                echo "$CLASSPATH"
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
          # TODO: Should do somthing about RegressionTest0, what about RegressionTestN
          inputs = [
            {
              name = "regression"; 
              args = [];
            }
            # { 
            #   name = "error";
            #   args = [ 
            #     "ErrorTest" 
            #   ];
            # }
          ];
        };
      };
}
