{ stdenv, fetchurl, ant, unzip }:
{ 
  name = "sunflow";
  mainclass = "org.sunflow.Benchmark";
  tags = [ "reflection-free" ];
  build = java: rec {
    version = "0.07.2";
    src = fetchurl {
      # Original mirror down... Same file
      url = ''http://prdownloads.sourceforge.net/sunflow/sunflow-src-v0.07.2.zip?download'';
      md5 = "aaaa162cf76cfdbc29381406c08671a9";
    };
    phases = [ "buildPhase" "installPhase" ];
    tags = [ "reflection-free" ];
    buildInputs = [ ant java.jdk unzip ];
    buildPhase = ''
      unzip $src
      cd sunflow
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
