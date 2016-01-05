{ stdenv, fetchzip, ant, subversion, daCapoSrc}:
let 
   batik = java: rec {
    version = "1.7beta1";
    src = fetchzip {
      url = ''http://archive.apache.org/dist/xmlgraphics/batik/batik-src-${version}.zip'';
      md5 = "dac6a6ce70013c839434e31563fea660";
    };
    buildInputs = [ ant java.jdk subversion ];
    buildPhase = "
      ls $src
      ant all-jar
    ";
    installPhase = ''
      mkdir -p $out/share/java
      mv batik-1.7/lib/batik-all.jar $out/share/java
      find lib -name '*.jar' -exec mv {} $out/share/java/ \;
    '';
  };
in { 
  name = "batik";
  jarfile = "batik-all.jar";
  mainclass = "org.apache.batik.apps.rasterizer.Main";
  build = batik;
  data = "${daCapoSrc}/benchmarks/bms/batik/data/batik/";
  # libraries = java: with java.libs; [ xalan xerces];
  inputs = [
    { name = "small";
      args = [
        "-d" "."
        "-scriptSecurityOff"
        "$data/mapWaadt.svg"
      ];
    }
  ];
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
