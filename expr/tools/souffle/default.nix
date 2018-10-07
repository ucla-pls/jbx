{ stdenv, fetchFromGitHub, mcpp
, boost, bison, flex, openjdk, doxygen
, perl, graphviz, ncurses, zlib, sqlite
, autoreconfHook }:

stdenv.mkDerivation rec {
  version = "1.4.0";
  name    = "souffle-${version}";

  src = fetchFromGitHub {
    owner  = "souffle-lang";
    repo   = "souffle";
    rev    = "c0ef14446bc3d48e68957d120af9b1a1c89782b3";
    sha256 = "0j70azbfn7w8230wj5zdvxs6w1759s3pwaq2gzl1w12lpwhkw23q";
  };

  nativeBuildInputs = [ autoreconfHook bison flex ];

  buildInputs = [
    boost openjdk doxygen perl graphviz 
  ];

  propagatedBuildInputs = [ 
    ncurses zlib sqlite mcpp
  ];

  patchPhase = ''
    substituteInPlace configure.ac \
      --replace "m4_esyscmd([git describe --tags --always | tr -d '\n'])" "${version}-c0ef144"
  '';

  # Without this, we get an obscure error about not being able to find a library version
  # without saying what library it's looking for. Turns out it's searching global paths
  # for boost and failing there, so we tell it what's what here.
  configureFlags = [ "--with-boost-libdir=${boost}/lib" ];

  meta = with stdenv.lib; {
    description = "A translator of declarative Datalog programs into the C++ language";
    homepage    = "http://souffle-lang.github.io/";
    platforms   = platforms.unix;
    maintainers = with maintainers; [ copumpkin wchresta ];
    license     = licenses.upl;
  };
}
