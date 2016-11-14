{ stdenv, daCapoSrc, fetchurl, fetchzip, unzip}:
rec {
  name = "xalan";
  mainclass = "Main";
  tags = [ "reflection-free" ];
  build = java: {
    version = ".";
    src = daCapoSrc;
    phases = [ "buildPhase" "installPhase" ];
    buildInputs = [ java.jdk ] ++ libraries java;
    harness = ./Main.java;
    buildPhase = ''
      cp $src/benchmarks/bms/xalan/src/org/dacapo/xalan/XSLTBench.java .
      cp $harness ./Main.java
      mkdir out
      javac ./XSLTBench.java -d out
      CLASSPATH=out:$CLASSPATH javac ./Main.java -d out
      cd out; jar vcf xalan-bench.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      cp xalan-bench.jar $_
    '';
  };
  data = fetchzip {
    url = "http://www.w3.org/TR/2001/WD-xforms-20010608/WD-xforms-20010608.zip";
    md5 = "8efa427e4e368cb0e2347b9491adac4c";
    stripRoot = false;
  };
  libraries = java: with java.libs; [ xalan xalan-serializer ];
  inputs = let SCRATCH = "."; setup = "ln -s ${data} xalan"; in [
    {
      name = "small";
      args = [ "${SCRATCH}" "1" "10" ];
      inherit setup;
    }
    {
      name = "default";
      args = [ "${SCRATCH}" "1" "100" ];
      inherit setup;
    }
    {
      name = "large";
      args = [ "${SCRATCH}" "1" "1000" ];
      inherit setup;
    }
  ];
}
