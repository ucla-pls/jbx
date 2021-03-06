{fetchurl, unzip, utils}:
let 
  dacapo-all = java: {
    src = 
    fetchurl {
      url = "https://sourceforge.net/projects/dacapobench/files/archive/9.12-bach/dacapo-9.12-bach.jar/download";
      md5 = "3f5c11927268b567bc90629c17ec446b";
    } ;
    phases = "installPhase";
    buildInputs = [ java.jdk ];
    installPhase = ''
    jar -xf $src
    mkdir -p $out/share/java
    # find . -name "*.jar" -exec cp {} $out/share/java \;
    cp $src $out/share/java/dacapo-9.12-bach.jar
    '';
  };

  dacapo-all-MR1 = java: {
    src = if java.version == 8 then
    fetchurl {
      url = "http://sourceforge.net/projects/dacapobench/files/9.12-bach-MR1/dacapo-9.12-MR1-bach.jar/download";
      md5 = "81a1e72daab989db1814fe7f765f8cee";
    } else 
    fetchurl {
      url = "https://sourceforge.net/projects/dacapobench/files/9.12-bach-MR1/dacapo-9.12-MR1-bach-java6.jar/download";
      md5 = "a2f76bc6a33c1f6730113124357eb73b";
    };
    phases = "installPhase";
    buildInputs = [ java.jdk ];
    installPhase = ''
    jar -xf $src
    mkdir -p $out/share/java
    # find . -name "*.jar" -exec cp {} $out/share/java \;
    cp $src $out/share/java/dacapo-9.12-MR1-bach.jar
    '';
  };
  harness-benchmark = options @ {
      name
    , sizes
    , jar ? "${name}.jar"
    , versions ? [ 5 6 7 8]
    , tags ? []
    }: 
    utils.mkBenchmarkTemplate {
      name = name + "-harness";
      build = dacapo-all;
      tags = tags ++ ["reflection" "dacapo-harness"];
      mainclass = "Harness";
      inputs = map (size: { name = size; args = ["--preserve" "-s" size name];}) sizes;
      filter = java: builtins.elem java.version versions;
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
    sizes = ["small" "default" "large"]; # -- also works on "huge"
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
    name = "lusearch-fix";
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
    sizes = ["small" "default" "large"]; # -- also works on "huge"
  }
  {
    name = "tradebeans";
    jar = "daytrader.jar";
    sizes = ["small" "default" "large"]; # -- also works on "huge"
  }
  {
    name = "tradesoap";
    jar = "daytrader.jar";
    sizes = ["small" "default" "large"]; # -- also works on "huge"
  }
  {
    name = "xalan";
    sizes = ["small" "default" "large"];
  }
]


