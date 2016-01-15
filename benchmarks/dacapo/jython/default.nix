{ fetchsvn, ant, subversion, daCapoSrc }:
{
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
  data = "${daCapoSrc}/benchmarks/bms/jython/data/jython";
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