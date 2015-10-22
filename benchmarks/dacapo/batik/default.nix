{ fetchzip, stdenv, ant, jdk6}:
let
  # This package needs jdk6
  pureBuild = stdenv.mkDerivation rec {
    name = "batik";
    version = "1.7beta1";
    src = fetchzip {
      url = ''http://archive.apache.org/dist/xmlgraphics/batik/batik-src-${version}.zip'';
      md5 = "dac6a6ce70013c839434e31563fea660";
      #packed = "fb1f6a7e996d44e417398e2f5067658b";
    };
    buildInputs = [ ant jdk6 ];
    buildPhase = "ant all-jar";
    installPhase = ''
      find . -name *.jar;
    '';
  };
in pureBuild
