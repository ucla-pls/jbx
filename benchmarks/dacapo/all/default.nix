{fetchurl, unzip, mkBenchmark}:
let 
  dacapo-all =  java: {
    src = fetchurl {
      url = "http://sourceforge.net/projects/dacapobench/files/9.12-bach/dacapo-9.12-bach.jar/download";
      md5 = "3f5c11927268b567bc90629c17ec446b";
    };
    phases = "installPhase";
    buildInputs = [ java.jdk ];
    installPhase = ''
    jar -xf $src
    mkdir -p $out/share/java
    find . -name "*.jar" -exec cp {} $out/share/java \;
    cp $src $out/share/java/dacapo-9.12-bach.jar
    '';
  };
  harness-benchmark = options @ {
      name
    , sizes 
    , java ? [ 5 6 7 8 ]
    }: 
    mkBenchmark {
      name = name + "-harness";
      mainclass = "org.dacapo.harness.TestHarness";
      build = dacapo-all;
      inputs = map (size: { name = size; args = ["-s" size "avrora"];}) sizes;
    };
in map harness-benchmark [
  {
    name = "avrora";
    sizes = ["small" "default" "large"];
  }
  {
    name = "batik";
    sizes = ["small" "default" "large"];
  }
  {
    name = "eclipse";
    sizes = ["small" "default" "large"];
  }
  {
    name = "fop";
    sizes = ["small" "default"];
  }
  {
    name = "h2";
    sizes = ["small" "default" "large" "huge"];
  }
  {
    name = "jython";
    sizes = ["small" "default" "large"];
  }
  {
    name = "luindex";
    sizes = ["small" "default"];
  }
  {
    name = "lusearch";
    sizes = ["small" "default" "large"];
  }
  {
    name = "pmd";
    sizes = ["xsmall" "small" "default" "large"];
  }
  {
    name = "sunflow";
    sizes = ["small" "default" "large"];
  }
  {
    name = "tomcat";
    sizes = ["small" "default" "large" "huge"];
  }
  {
    name = "tradebeans";
    sizes = ["small" "default" "large" "huge"];
  }
  {
    name = "tradesoap";
    sizes = ["small" "default" "large" "huge"];
  }
  {
    name = "xalan";
    sizes = ["small" "default" "large"];
  }
]


