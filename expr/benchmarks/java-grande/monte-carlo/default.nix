{ java-grande-src }:
rec {
  name = "monte-carlo";
  mainclass = "JGFMonteCarloBenchSizeA";
  build = java: {
    src = java-grande-src;
    phases = ["unpackPhase" "buildPhase" "installPhase"];
    buildInputs = [ java.jdk ];
    unpackPhase = ''
      tar -xzvf $src
    '';
    buildPhase = ''
      cd java_grande
      mkdir monte-carlo
      javac src/jgfutil/*.java \
        section3/montecarlo/*.java \
        section3/JGFMonteCarloBenchSizeA.java \
        section3/JGFMonteCarloBenchSizeB.java \
        -d monte-carlo
      jar cvf monte-carlo.jar -C monte-carlo .
    '';
    installPhase = ''
      mkdir -p $out/share/java
      mv monte-carlo.jar $_
      mkdir -p $out/data
      cp section3/Data/hitData $_/
    '';
  };
  inputs = [
    {
      name ="default";
      args = [
        "5"
        "$data/data"
        "hitData"
      ];
    }
  ];
}
