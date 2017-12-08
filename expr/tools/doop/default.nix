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
   version = "3.2.13";
   src = fetchgit {
     url = "https://bitbucket.org/yanniss/doop.git";
     rev = "517d75584d6d6db799c7d12ef6a4600070b9d8b0";
     sha256 = "01x63biajll9npcs5wsan6ldx8acvkf4z3ikjrfjc7c96a30fm2n";
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

   phases = [ "unpackPhase" "buildPhase" "installPhase" ];
 
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
