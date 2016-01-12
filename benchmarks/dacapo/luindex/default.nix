{ daCapoSrc }:
rec {
  name = "luindex";
  mainclass = "org.dacapo.luindex.Index";
  build = java: {
    version = ".";
    src = daCapoSrc;
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ java.jdk ] ++ libraries java;
    buildPhase = ''
      cd benchmarks/bms/luindex
      mkdir out
      javac src/org/dacapo/luindex/Index.java -d out
    '';
  };
  libraries = java: with java.libs; [ luscene ];
}
