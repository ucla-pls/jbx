{ fetchurl
, libtool
, automake
, cmake
, autoconf
, git
, ncurses
, zlib
, sqlite
, getopt
, lsb-release
, bison
, boost
, openjdk
, doxygen
, perl
, graphviz
, flex
, stdenv
, gradle
, makeWrapper
}:
stdenv.mkDerivation rec {
  version = "1.2.0";
  name = "souffle-${version}";
  src = fetchurl {
    url = "https://github.com/souffle-lang/souffle/archive/${version}.tar.gz";
    sha256 = "1isrblmj06cpfrgnyhwx9wwxfciwmbzqw097ca6cnxslyq6dl2y4";
  };

  buildInputs = [
    libtool git
    lsb-release getopt
    autoconf automake boost bison flex openjdk
    zlib sqlite
    ncurses
    # Used for docs
    doxygen perl graphviz
    makeWrapper
  ];

  configureFlags = [ "--with-boost-libdir=${boost}/lib" ];

  preConfigure = ''
    substituteInPlace configure.ac \
       --replace "m4_esyscmd([git describe --tags --abbrev=0 --always | tr -d '\n'])" "${version}"

    sh ./bootstrap
   '';
 
  #  postInstall = ''
  #  mv $out/bin/souffle $out/bin/souffle_unwrapped
  #  makeWrapper $out/bin/souffle_unwrapped $out/bin/souffle \
  #    --suffix-each LD_LIBRARY_PATH : $(zlib)/lib
  #  '';
}
