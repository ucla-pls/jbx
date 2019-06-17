{ stdenv, fetchurl, unzip, ant }:
rec {
  wala-1_5_0 = stdenv.mkDerivation {
    name = "WALA-1.5.0";
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

  wala-1_5_3 = stdenv.mkDerivation {
    name = "WALA-1.5.3";
    core = fetchurl { 
      url = "http://central.maven.org/maven2/com/ibm/wala/com.ibm.wala.core/1.5.3/com.ibm.wala.core-1.5.3.jar";
      sha256 = "07xxwghigg0s0b2787sfg7nkbmvbjr8lw9zsdhz13sn718w34dgc";
    };
    shrike = fetchurl { 
      url = "http://central.maven.org/maven2/com/ibm/wala/com.ibm.wala.shrike/1.5.3/com.ibm.wala.shrike-1.5.3.jar";
      sha256 = "1ycqiaxjwl68s3qpdgy7j6a9rahyyfa01rg5ll07ig3kbilk5kj9";
    };
    util = fetchurl { 
      url = "http://central.maven.org/maven2/com/ibm/wala/com.ibm.wala.util/1.5.3/com.ibm.wala.util-1.5.3.jar";
      sha256 = "098zmrgiy3am0xzlzbghvv59rp2vmsrdgbbsd82aaliljwr3wlyf";
    };
    phases = "installPhase";
    installPhase = ''
    mkdir -p $out/share/java/
    cp $core $out/share/java/core.jar
    cp $shrike $out/share/java/shrike.jar
    cp $util $out/share/java/util.jar
    '';
  };
  wala = wala-1_5_3;
}
