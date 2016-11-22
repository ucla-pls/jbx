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
  java-grande-benchmark = {
    name,
    mainclass,
    inputs
  }: mkBenchmarkTemplate {
    inherit name mainclass inputs;
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
  };
in rec {
  monte-carlo-a = java-grande-benchmark {
    name = "monte-carlo-a";
    mainclass = "JGFMonteCarloBenchSizeA";
    inputs = [ {
      name ="default";
      args = [
        "5"
        "$data/data"
        "hitData"
      ];
    } ];
  };

  monte-carlo-b = java-grande-benchmark {
    name = "monte-carlo-b";
    mainclass = "JGFMonteCarloBenchSizeB";
    inputs = [ {
      name ="default";
      args = [
        "5"
        "$data/data"
        "hitData"
      ];
    } ];
  };

  mol-dyn-a = java-grande-benchmark {
    name = "mol-dyn-a";
    mainclass = "JGFMolDynBenchSizeA";
    inputs = [ {
      name ="default";
      args = [ "5" ];
    } ];
  };

  mol-dyn-b = java-grande-benchmark {
    name = "mol-dyn-b";
    mainclass = "JGFMolDynBenchSizeB";
    inputs = [ {
      name ="default";
      args = [ "5"];
    } ];
  };

  ray-tracer-a = java-grande-benchmark {
    name = "ray-tracer-a";
    mainclass = "JGFRayTracerBenchSizeA";
    inputs = [ {
      name ="default";
      args = [ "5"];
    } ];
  };

  ray-tracer-b = java-grande-benchmark {
    name = "ray-tracer-b";
    mainclass = "JGFRayTracerBenchSizeB";
    inputs = [ {
      name ="default";
      args = [ "5"];
    } ];
  };

  all = [
    monte-carlo-a
    monte-carlo-b
    mol-dyn-a
    mol-dyn-b
    ray-tracer-a
    ray-tracer-b
    # mol-dyn
  ];
}
