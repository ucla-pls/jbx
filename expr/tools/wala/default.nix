{ stdenv, fetchurl, unzip, ant }:
rec {
  wala-1_5_0 = stdenv.mkDerivation {
    name = "WALA";
    core = fetchurl { 
      url = "http://central.maven.org/maven2/com/ibm/wala/com.ibm.wala.core/1.5.0/com.ibm.wala.core-1.5.0.jar";
      sha256 = "02rpd50irsgk7bp8skiw0swnpz27r2m8yjc6k4xlniyhnkindzmg";
    };
    shrike = fetchurl { 
      url = "http://central.maven.org/maven2/com/ibm/wala/com.ibm.wala.shrike/1.5.0/com.ibm.wala.shrike-1.5.0.jar";
      sha256 = "08kvniip59a401b0k2b0kszrn7c7ddr5dif8w7ixqyn1gm3wjbq0";
    };
    util = fetchurl { 
      url = "http://central.maven.org/maven2/com/ibm/wala/com.ibm.wala.util/1.5.0/com.ibm.wala.util-1.5.0.jar";
      sha256 = "1xkqvj6sqa0f3dq8yf6pqjrr79r77vj49phc4vqr7gf92xjmnfdy";
    };
    phases = "installPhase";
    installPhase = ''
    mkdir -p $out/share/java/
    cp $core $out/share/java/core.jar
    cp $shrike $out/share/java/shrike.jar
    cp $util $out/share/java/util.jar
    '';
  };
  wala = wala-1_5_0;
}
