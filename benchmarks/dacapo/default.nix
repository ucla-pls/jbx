{ pkgs } :
let
  inherit (pkgs) stdenv unzip;
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

  avrora = import ./avrora { jversion = 7; } pkgs;

  # Warning not equivlient to dacapo, uses newer version.
  batik = pkgs.callPackage ./batik {};

  # Does not work .. no eclipse found
  # eclipse = pkgs.callPackage ./eclipse { };

  fop = pkgs.callPackage ./fop {};

}
