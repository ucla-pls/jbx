{ daCapoSrc}:
rec {
  name = "lusearch";
  mainclass = "org.dacapo.lusearch.Search";
  build = java: {
    version = ".";
    phases = [ "buildPhase" "installPhase" ];
    buildInputs = [ java.jdk ] ++ libraries java;
    harness = ./Search.java;
    buildPhase = ''
      mkdir out
      cp $harness ./Search.java
      javac ./Search.java -d out
      cd out; jar vcf lusearch.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      cp lusearch.jar $_
    '';
  };
  data = daCapoSrc;
  libraries = java: with java.libs; [ lucene-core lucene-demos ];
  inputs = let 
    SCRATCH="$data/benchmarks/bms/lusearch/data"; 
    THREADS="64";
  in [
    { name = "small";
    args = [ 
      "-index" "${SCRATCH}/lusearch/index-default" 
      "-queries" "${SCRATCH}/lusearch/query" 
      "-output" "lusearch.out" 
      "-totalqueries" "8" 
      "-threads" "${THREADS}"];
    }
    { name = "default";
    args = [
      "-index" "${SCRATCH}/lusearch/index-default"
      "-queries" "${SCRATCH}/lusearch/query"
      "-output" "lusearch.out"
      "-totalqueries" "64"
      "-threads" "${THREADS}"
    ];
    }
  ];
}
