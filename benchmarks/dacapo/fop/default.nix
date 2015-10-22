{ stdenv, fetchurl, ant, jdk7 }:
let
  build = stdenv.mkDerivation rec {
    name = "fop";
    version = "0.95";
    src = fetchurl {
      url = ''http://archive.apache.org/dist/xmlgraphics/fop/source/fop-${version}-src.tar.gz'';
      md5 = "58593e6c86be17d7dc03c829630fd152";
      #packed = "fb1f6a7e996d44e417398e2f5067658b";
    };
    buildInputs = [ ant jdk7 ];
    buildPhase = "ant";
    installPhase = ''
      mkdir -p $out/share/java
      mv build/*.jar $out/share/java/
    '';
  };
in build
