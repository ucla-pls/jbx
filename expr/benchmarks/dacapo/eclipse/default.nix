{ stdenv, fetchurl}: 
let 
  pureBuild = stdenv.mkDerivation rec {
    name = "eclipse";
    version = "3.5.1";
    src = fetchurl {
      url = "http://download.eclipse.org/eclipse/downloads/drops/R-${version}-200909170800/eclipse-SDK-${version}-macosx-cocoa.tar.gz";
      md5 = "b44b94a9ab6caec3aa436e942708ae25";
    };
  };
in pureBuild
