{ pkgs } :
let inherit (pkgs) stdenv unzip jdk7 jre7;
in rec {
  daCapoSrc = stdenv.mkDerivation {
    name = "DaCapo";
    version = "9.12";
    src = ./dacapo-9.12-bach-src.zip;
    buildInputs = [ unzip ];
    unpackPhase='' 
      unzip $src
      sourceRoot=.
    '';
    installPhase=''
      mkdir $out
      cp -r * $out
    '';
    dontFixup=true;
  };

  avrora = pkgs.callPackage ./avrora { 
    inherit daCapoSrc; 
    jdk = jdk7; 
  };

  batik = pkgs.callPackage ./batik { };

  eclipse = pkgs.callPackage ./eclipse { };

  fop = pkgs.callPackage ./fop {};

}
