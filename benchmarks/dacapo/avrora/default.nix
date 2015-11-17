{ stdenv, fetchcvs, daCapoSrc, ant, jdk7, cvs}: 
let 
  # Reference implementation
  build = stdenv.mkDerivation {
    name = "dacapo-avrora";
    src = daCapoSrc;
    builder = ./builder.sh;
    buildInputs = [ ant jdk7 cvs];
  };
  # Like the build but without using the daCapoSrc, the pure build is
  # preferable because it is without harness and cache the downloads of
  # 'avrora', and hash checks it.
  pureBuild = stdenv.mkDerivation {
    name = "avrora";
    version = "beta-1.7.110";
    src = fetchcvs {
      cvsRoot = ":pserver:anonymous@avrora.cvs.sourceforge.net:/cvsroot/avrora";
      date = "20091224";
      module = "avrora";
      sha256 = "0kki6ab9gibyrfbx3dk0liwdp5dz8pzigwf164jfxhwq3w8smfxn";
    };
    buildInputs = [ ant jdk7 ];
    builder = ./pure-builder.sh;
  };
# Only allow acces to the pure build, as the other is broken
in {
  name = "Avrora";
  build = pureBuild;
  jarfile = "avrora-beta-1.7.110.jar";
  mainclass = "avrora.Main";
  jreversion = "7";
  runs = [];
}
