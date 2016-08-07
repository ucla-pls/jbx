{ utils, wiretap }:
options @ {
}:
benchmark:
env:
input:
let
  wiretapped = benchmark:
    utils.mkDynamicAnalysis {
      name = "wiretap";
      timelimit = 1800;
      wiretap = wiretap benchmark.java;
      analysis = ''
        echo $classpath
        analyse "wiretap-run" java -javaagent:$wiretap/share/java/wiretap.jar \
          -cp $classpath $mainclass $args < $stdin
      '';
    } benchmark;
in
wiretapped benchmark env input
