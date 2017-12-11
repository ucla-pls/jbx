{ souffle
, gradle
, fetchgit
, gnumake
, cmake
, zlib
, sqlite
, glibcLocales
, ncurses
, openjdk
, stdenv
, fetchurl
, libtool
, makeWrapper
}:
stdenv.mkDerivation rec {
   name = "doop-${version}";
   version = "3.3.1";
   src = fetchgit {
     url = "https://bitbucket.org/yanniss/doop.git";
     rev = "c34adb68a1ce588e943ff35a0f8395d1e8fb251b";
     sha256 = "01bkj1w4h2msqfi0d3ar5jkjzsjf4azdl962j0mdd595abk25nd6";
     branchName = "master";
   };

#   outputHashAlgo = "sha256";
#   outputHash = "0810nv4aarrdlw7n7kvb6yjbgmmv13ka6qglfcb90f36vazmhp27";
#   outputHashMode = "recursive";

   buildInputs = [
     gradle
     gnumake
     souffle
     cmake
     zlib
     sqlite
     glibcLocales
     ncurses
     libtool
     openjdk
     makeWrapper
   ];

   phases = [ "unpackPhase" "patchPhase" "buildPhase" "installPhase" ];

   patches = [ ./nobash.patch ];

   buildPhase = '' 
    gradle -g /tmp distTar
    tar -xf build/distributions/${name}.tar
    cd ${name}
   '';

   installPhase = ''
     mkdir -p $out
     cp -r bin/ $out/bin
     mkdir -p $out/share/java
     cp -r lib/* $out/share/java
     cp -r logic $out/logic
     cp -r souffle-logic $out/souffle-logic
     ln -s $out/share/java $out/lib
     mv $out/bin/doop $out/bin/doop_unwrapped
 
     makeWrapper $out/bin/doop_unwrapped $out/bin/doop \
       --set DOOP_HOME $out/ \
       --prefix PATH : ${souffle}/bin
   '';
}
