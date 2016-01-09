{ stdenv, fetchzip, ant, subversion, daCapoSrc}:
let 
   batik = java: rec {
    version = "1.7beta1";
    src = fetchzip {
      url = ''http://archive.apache.org/dist/xmlgraphics/batik/batik-src-${version}.zip'';
      md5 = "dac6a6ce70013c839434e31563fea660";
    };
    buildInputs = [ ant java.jdk subversion ];
    ANT_OPTS="-Xms256m -Xmx256m";
    buildPhase = "
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
  mainclass = "org.apache.batik.apps.rasterizer.Main";
  build = batik;
  data = "${daCapoSrc}/benchmarks/bms/batik/data/batik/";
  # libraries = java: with java.libs; [ xalan xerces];
  filter = java: builtins.elem java.version [5 6];
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
