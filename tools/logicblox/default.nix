{ stdenv, fetchprop }:
{
logicblox3 = stdenv.mkDerivation {
  name = "logicblox";
  version = "3.10.21";
  src = fetchprop {
    url = "logicblox-3.10.21.tar.gz";
    md5 = "75611acbc5f6fdd48f22e2a68809b1d4";
  };
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
  installPhase = "
  
    cp -r logicblox/* $out
  ";
};
logicblox4 = stdenv.mkDerivation {
  name = "logicblox";
  version = "4.2.0";
  src = fetchprop {
    url = "logicblox-4.2.0.tar.gz";
    md5 = "b179aa5df2d74830bbbf845a82f831da";
  };
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
  installPhase = " 
    mkdir $out
    cp -r * $out
  ";

  postFixup = ''
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      "$out/bin/lb-pager"

    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      "$out/bin/lb-server"
  '';
};
}
