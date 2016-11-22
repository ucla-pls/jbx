{ callPackage, utils }:
let
  inherit (utils) callBenchmark mkBenchmarkTemplate fetchprop;
  # Same as:
  # callBenchmark = utils.callBenchmark;
  # fetchprop = utils.fetchprop;
  java-grande-src = fetchprop {
     url="java_grande.tar.gz";
     sha256="10mfasrbga7zvf51pybvp1cwwllm26i6c2v6w0gyay69nsb5sh91";
  };
in rec {
  build = java: {
    src = java-grande-src;
    phases = ["unpackPhase" "buildPhase" "installPhase"];
    buildInputs = [ java.jdk ];
    unpackPhase = ''
      tar -xzvf $src
    '';
    buildPhase = ''
      cd java_grande
      mkdir java-grande-section3
      javac src/jgfutil/*.java \
        section3/montecarlo/*.java \
        section3/moldyn/*.java \
        section3/raytracer/*.java \
        section3/JGFMonteCarloBenchSizeA.java \
        section3/JGFMonteCarloBenchSizeB.java \
        section3/JGFMolDynBenchSizeA.java \
        section3/JGFMolDynBenchSizeB.java \
        section3/JGFRayTracerBenchSizeA.java \
        section3/JGFRayTracerBenchSizeB.java \
        -d java-grande-section3
      jar cvf java-grande-section3.jar -C java-grande-section3 .
    '';
    installPhase = ''
      mkdir -p $out/share/java
      mv java-grande-section3.jar $_
      mkdir -p $out/data
      cp section3/Data/hitData $_/
    '';
  };

  monte-carlo-A = mkBenchmarkTemplate ((callPackage ./monte-carlo { inherit build; }) "A");
  monte-carlo-B = mkBenchmarkTemplate ((callPackage ./monte-carlo { inherit build; }) "B");
  ray-tracer = callBenchmark ./ray-tracer { inherit java-grande-src; };
  mol-dyn = callBenchmark ./mol-dyn { inherit java-grande-src; };

  all = [
    monte-carlo-A
    monte-carlo-B
    # ray-tracer
    # mol-dyn
  ];
}
