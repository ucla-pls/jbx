{ fetchzip, ant, mkBenchmark}:
mkBenchmark { 
  name = "balik";
  jarfile = "batik-all.jar";
  mainclass = "main.Clsass";
  build = java: rec {
    version = "1.7beta1";
    src = fetchzip {
      url = ''http://archive.apache.org/dist/xmlgraphics/batik/batik-src-${version}.zip'';
      md5 = "dac6a6ce70013c839434e31563fea660";
    };
    buildInputs = [ ant java.jdk ];
    buildPhase = "ant all-jar";
    installPhase = ''
      mkdir -p $out/share/java
      mv batik-1.7/lib/batik-all.jar $out/share/java
    '';
  };
}

# let
#   # This package needs jdk6
#   pureBuild = stdenv.mkDerivation rec {
#     name = "batik";
#     version = "1.7beta1";
#     src = fetchzip {
#       url = ''http://archive.apache.org/dist/xmlgraphics/batik/batik-src-${version}.zip'';
#       md5 = "dac6a6ce70013c839434e31563fea660";
#       #packed = "fb1f6a7e996d44e417398e2f5067658b";
#     };
#     buildInputs = [ ant jdk7 ];
#     buildPhase = "ant all-jar";
#     installPhase = ''
#       find . -name *.jar;
#     '';
#   };
#   buildAlternative = stdenv.mkDerivation rec { 
#     name = "batik";
#     version = "1.7";
#     src = fetchzip { 
#       url = "http://apache.osuosl.org/xmlgraphics/batik/source/batik-src-${version}.zip";
#       md5 = "ca88e823c57d10611aa0839570711661";
#     };
#     buildInputs = [ ant jdk7 ];
#     buildPhase = "ant all-jar";
#     installPhase = ''
#       mkdir -p $out/share/java
#       mv batik-${version}/lib/batik-all.jar $out/share/java
#     '';
#   };
# in {
#     name = "batik_${toString jversion_}";
#     build = pureBuild;
#     jversion = jversion_;
#     inputs = [];
# }
