{ souffle
, gradle
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
  src = fetchurl {
    url = "file:///home/nodnerb/jbx/expr/tools/newDoop/${name}.tar";
    sha256 = "12jw7byd6905kd2m36jg13i4iay6903sls1rabgdqzg71sxadf5m";
  };

  buildInputs = [
     gradle
     gnumake
  #   souffle
     cmake
     libtool
     openjdk
     makeWrapper
   ];

  propagatedBuildInputs = [
     zlib
     sqlite
     glibcLocales
     ncurses
     souffle
     cmake
  ];

  phases = [ "unpackPhase" "installPhase" ];

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
      --prefix PATH : ${souffle}/bin \
      --set NIX_LDFLAGS '-L${zlib}/lib -L${sqlite}/lib -L${ncurses}/lib' \
      --set NIX_CFLAGS_COMPILE '-isystem ${zlib.out}/include -isystem ${sqlite.out}/include -isystem ${ncurses.out}/include'
  '';

}
#stdenv.mkDerivation rec {
#   name = "doop";
#   src = fetchgit {
#     url = "https://bitbucket.org/yanniss/doop.git";
#     rev = "517d75584d6d6db799c7d12ef6a4600070b9d8b0";
#     sha256 = "01x63biajll9npcs5wsan6ldx8acvkf4z3ikjrfjc7c96a30fm2n";
#     branchName = "master";
#   };
#   buildInputs = [
#     gradle
#     gnumake
#     souffle
#     cmake
#     zlib
#     sqlite
#     glibcLocales
#     ncurses
#     libtool
#     openjdk
#   ];
#
#   phases = [ "unpackPhase" "buildPhase" ];
# 
#   buildPhase = ''
#    gradle distTar
#   '';
# }
