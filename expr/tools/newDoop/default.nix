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
, fetchgit
, libtool
}:
stdenv.mkDerivation rec {
  name = "doop";
  src = fetchgit {
    url = "https://bitbucket.org/yanniss/doop.git";
    rev = "517d75584d6d6db799c7d12ef6a4600070b9d8b0";
    sha256 = "01x63biajll9npcs5wsan6ldx8acvkf4z3ikjrfjc7c96a30fm2n";
    branchName = "master";
  };
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
  ];

  phases = [ "unpackPhase" "buildPhase" ];

  buildPhase = ''
   gradle distTar
  '';
}
