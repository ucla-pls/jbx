{ stdenv, fetchsvn, fetchurl, ant, subversion, daCapoSrc }:
let pybench = stdenv.mkDerivation {
  name = "pybench";
  src = fetchurl {
    url = "http://www.python.org/ftp/python/2.5.4/Python-2.5.4.tgz";
    md5 = "ad47b23778f64edadaaa8b5534986eed";
  };
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    cp -r Tools/pybench $out
    cp -r Lib/* $out
    cp ${daCapoSrc}/benchmarks/bms/jython/data/jython/sieve.py $out
  '';
};
in {
  name = "jython";
  mainclass = "org.python.util.jython";
  version = "2.5.1";
  build = java: {
    src = fetchsvn {
      url = "http://svn.code.sf.net/p/jython/svn/tags/Release_2_5_1/jython";
      rev = "6571";
      md5 = "c165057812bcba4d57195c2eb05817ce";
    };
    buildInputs = [ ant java.jdk subversion ];
    buildPhase = "ant";
    installPhase = ''
      mkdir -p $out/share/java
      find dist -name '*.jar' -exec mv {} $out/share/java \;
    '';
  };
  data = pybench;
  filter = java: builtins.elem java.version [5 6 7];
  inputs = [
    {
      name = "small";
      args = [
        "$data/sieve.py"
        "50"
      ];
    }
  ];
}