{stdenv, fetchurl}: java:
let
  fetchmvn = options @ {
    name
    , version
    , md5 ? "00000000000000000000000000000000"
    , group ? name
    , jar ? "${name}-${version}.jar"
    , base ? "http://central.maven.org/maven2"
    }:
    stdenv.mkDerivation {
      name = name;
      version = version;
      src = fetchurl {
        url = "${base}/${builtins.replaceStrings ["."] ["/"] group}/${name}/${version}/${jar}";
        md5 = md5;
      };
      phases = [ "installPhase" ];
      installPhase = ''
      mkdir -p $out/share/java
      cp $src $_
      '';
    };
in
{
  lucene-core = fetchmvn {
    name = "lucene-core";
    version = "2.4.1";
    group = "org.apache.lucene";
    md5 = "50373bca7c7436d4b9741a3a8e972a3a"; 
  };
  
  lucene-demo = fetchmvn {
    name = "lucene-demos";
    version = "2.4.1";
    group = "org.apache.lucene";
    md5 = "472e1a9dbced6d1948bf80caebcc7dec"; 
  };

  commons-io = fetchmvn {
    name = "commons-io";
    version = "1.3.1";
    group = "org.apache.commons";
    md5 = "50373bca7c7436d4b9741a3a8e972a3a"; 
  };
  
  commons-cli = fetchmvn {
    name = "commons-io";
    version = "1.2";
    group = "org.apache.commons";
    md5 = "50373bca7c7436d4b9741a3a8e972a3a"; 
  };

  commons-logging = fetchmvn {
    name = "commons-logging";
    version = "1.3.1";
    group = "org.apache.commons";
    md5 = "50373bca7c7436d4b9741a3a8e972a3a"; 
  };

  xmlgraphics-commons = fetchmvn {
    name = "xmlgraphics-commons";
    version = "1.3.1";
    group = "org.apache.xmlgraphics";
    md5 = "e63589601d939739349a50a029dab120"; 
  };

  jaxen = fetchmvn {
    name = "jaxen";
    version = "1.1.1";
    md5 = "261d1aa59865842ecc32b3848b0c6538";
  };
  
  derby = fetchmvn {
    name = "derby";
    group = "org.apache.derby";
    version = "10.5.3.0";
    md5 = "35367c636ce035102a039a19ca707986";
  };

  xalan = fetchmvn {
    name = "xalan";
    version = "2.7.1";
    md5 = "35367c636ce035102a039a19ca707986";
  };

  xerces = fetchmvn {
    name = "xerces";
    version = "2.8.0";
    md5 = "35367c636ce035102a039a19ca707986";
  };

  ant = fetchmvn {
    name = "ant";
    group = "org.apache.ant";
    version = "1.8.2";
    md5 = "9463f65940f928d650a95aeb057a4e0a";
  };

  h2 = fetchmvn {
    name = "h2";
    version = "1.2.121";
    group = "com.h2database";
    md5 = "9c7f583cadeeb6f2a940c9502fc9780a";
  };

  batik-util = fetchmvn {
    name = "batik-util";
    version = "1.7";
    group = "org.apache.xmlgraphics";
    md5 = "99f99684b6df6200e529575dccce9970";
  };
}
