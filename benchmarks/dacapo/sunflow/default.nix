{ stdenv, fetchzip, ant}:
{ 
  name = "sunflow";
  mainclass = "org.sunflow.Benchmark";
  jarfile = "sunflow.jar";
  build = java: rec {
    version = "0.07.2";
    src = fetchzip {
      # Original mirror down... Same file
      url = ''http://skylineservers.dl.sourceforge.net/project/sunflow/sunflow-src/v0.07.2/sunflow-src-v0.07.2.zip'';
      md5 = "352e6c1e618b6eb7cd90ca3de55ba148";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      ant jars
    '';
    installPhase = ''
      mkdir -p $out/share/java
      mv release/sunflow.jar $_ 
      mv janino.jar $_ 
      
      # Also remember the data
      mv resources $out
    '';
  };
  # data = "${daCapoSrc}/benchmarks/bms/batik/data/batik/";
  # libraries = java: with java.libs; [ xalan xerces];
  inputs = let 
    setup = ''cp -r $data/resources . '';
    in [
    { name = "small";
      inherit setup;
      args = [ "-bench" "2" "32" ];
      }
    { name = "default";
      args = [ "-bench" "2" "256" ];
      inherit setup;
      }
    { name = "large";
      args = [ "-bench" "2" "512" ];
      inherit setup;
      }
  ];
}
