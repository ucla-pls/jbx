{ utils, wiretap, lib}:
options @ {
  postprocess ? "",
  settings ? []
}:
benchmark:
env:
input:
let
  inherit (lib.strings) concatStringsSep concatMapStringsSep;
  ppsettings = concatMapStringsSep " " (o: "-Dwiretap.${o.name}=${o.value}");

  wiretapped = benchmark:
    utils.mkDynamicAnalysis {
      name = "wiretap";
      timelimit = 1800;
      wiretap = wiretap benchmark.java;
      settings = ppsettings ( [
        ] ++ settings );
      analysis = ''
        echo $classpath
        analyse "wiretap-run" java -javaagent:$wiretap/share/java/wiretap.jar \
          $settings\
          -cp $classpath $mainclass $args < $stdin
      '';
      inherit postprocess;
    } benchmark;
in
wiretapped benchmark env input
