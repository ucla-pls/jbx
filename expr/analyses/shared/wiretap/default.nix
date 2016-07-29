{ utils, wiretap }:
options @ {
}:
benchmark:
env:
input:
let
  wiretapped = utils.mkDynamicAnalysis {
    name = "wiretap";
    timelimit = 1800;
    wiretap = wiretap;
    analysis = ''
      mkdir inst
      echo $classpath
      analyse "wiretap-instrument" java -jar $wiretap/share/java/svm.jar -d inst \
        -cp $classpath $mainclass

      analyse "wiretap-run" java -cp $wiretap/share/java/svm.jar:inst svm.Main \
         --output trace.log $mainclass $args < $stdin
    '';
  };
in
wiretapped benchmark env input
