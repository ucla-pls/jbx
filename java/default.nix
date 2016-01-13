# The porpose of this module is to create the java versions used in the
# benchmarks. Besides a version of jdk and jre, the java collections will also
# contain some libraries which can be used in the contex of the benchmarks.
{ pkgs }:
let
  extendsion = {
    fetchmvn = 
      options @ {
        name
        , version
        , md5 ? "00000000000000000000000000000000"
        , group ? name
        , jar ? "${name}-${version}.jar"
        , base ? "http://central.maven.org/maven2"
      }:
      pkgs.stdenv.mkDerivation {
        name = name;
        version = version;
        src = pkgs.fetchurl {
          url = "${base}/${builtins.replaceStrings ["."] ["/"] group}/${name}/${version}/${jar}";
          md5 = md5;
        };
        phases = [ "installPhase" ];
        installPhase = ''
          mkdir -p $out/share/java
          cp $src $_
        '';
      };
  };
  mkJava = version: let 
    java = {
      id = "J${toString version}";
      version = version;
      jre = builtins.getAttr "jre${toString version}" pkgs;
      jdk = builtins.getAttr "jdk${toString version}" pkgs;
      libs = libs;
    };
    callLib = path: pkgs.lib.callPackageWith (pkgs // extendsion) path {} java;
    libs = {
      common-cli = callLib ./common-cli;
      xalan = callLib ./xalan;
      xerces = callLib ./xerces;
      jaxen = callLib ./jaxen;
      ant = callLib ./ant;
      lucene-core = callLib ./lucene-core;
      lucene-demos = callLib ./lucene-demos;
      h2 = callLib ./h2;
      derby = callLib ./derby;
    };
    in java;
in rec {
  java5 = mkJava 5;
  java6 = mkJava 6;
  java7 = mkJava 7;
  java8 = mkJava 8;
  all = [ java5 java6 java7 java8 ];
}


