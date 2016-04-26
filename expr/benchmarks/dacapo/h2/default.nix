{ ant, daCapoSrc }:
rec {
  name = "h2";
  mainclass = "org.dacapo.harness.H2";
  build = java: {
    src = daCapoSrc;
    buildInputs = [ ant java.jdk ] ++ libraries java;
    buildPhase = "
      cd benchmarks/bms/h2
      mkdir out
      javac src/org/dacapo/h2/TPCC.java -sourcepath src -d out
    ";
    installPhase = ''

    '';
  };
  libraries = java: with java.libs; [ h2 derby ];
  inputs = [
    {
      name = "small";
      args = [
        "--total-transactions" "400"
        "--scale" "2"
        "--cleanup-in-iteration"
        "--create-suffix" ";MVCC=true"
      ];
    }
    {
      name = "default";
      args = [
        "--total-transactions" "4000"
        "--scale" "8"
        "--cleanup-in-iteration"
        "--create-suffix" ";MVCC=true"
      ];
    }
    {
      name = "large";
      args = [
        "--total-transactions" "32000"
        "--scale" "8"
        "--cleanup-in-iteration"
        "--create-suffix" ";MVCC=true"
      ];
    }
    {
      name = "huge";
      args = [
        "--total-transactions" "256000"
        "--scale" "32"
        "--cleanup-in-iteration"
        "--create-suffix" ";MVCC=true"
      ];
    }
  ];
}
