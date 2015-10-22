{ stdenv, fetchcvs, daCapoSrc, ant, jdk, cvs}: 
{
  # Reference implementation
  build = stdenv.mkDerivation {
    name = "dacapo-avrora";
    src = daCapoSrc;
    builder = ./builder.sh;
    buildInputs = [ ant jdk cvs];
  };
  # Like the build but without using the daCapoSrc, the pure build is
  # preferable because it is without harness and cache the downloads of
  # 'avrora', and hash checks it.
  pureBuild = stdenv.mkDerivation {
    name = "avrora";
    src = fetchcvs {
      cvsRoot = ":pserver:anonymous@avrora.cvs.sourceforge.net:/cvsroot/avrora";
      date = "20091224";
      module = "avrora";
      sha256 = "0kki6ab9gibyrfbx3dk0liwdp5dz8pzigwf164jfxhwq3w8smfxn";
    };
    buildInputs = [ ant jdk ];
    builder = ./pure-builder.sh;
  };
}
