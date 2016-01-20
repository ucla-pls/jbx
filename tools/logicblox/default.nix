{ stdenv, fetchprop, jdk7, makeWrapper }:
{
logicblox-3_10_21 = stdenv.mkDerivation {
  name = "logicblox";
  version = "3.10.21";
  src = fetchprop {
    url = "logicblox-3.10.21.tar.gz";
    md5 = "75611acbc5f6fdd48f22e2a68809b1d4";
  };
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
  installPhase = ''
    cp -r logicblox/* $out
  '';
};
logicblox-4_2_0 = stdenv.mkDerivation {
  name = "logicblox";
  version = "4.2.0";
  src = fetchprop {
    url = "logicblox-4.2.0.tar.gz";
    md5 = "b179aa5df2d74830bbbf845a82f831da";
  };
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
  buildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir $out
    cp -r * $out
  '';

  postFixup = ''
    find $out -type f -perm -0100 \
        -exec patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" {} \;
    wrapProgram $out/bin/lb \
      --prefix PATH : ${jdk7}/bin/
  '';
};
}
