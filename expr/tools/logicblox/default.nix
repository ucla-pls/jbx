{ stdenv, fetchprop, jdk7, makeWrapper }:
let lb4 =
options @ {
  version,
  url ? "logicblox-${version}.tar.gz",
  md5 ? "00000000000000000000000000000000",
}: stdenv.mkDerivation {
  name = "logicblox";
  inherit version;
  src = fetchprop { inherit url md5; };
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
in {
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
  logicblox-4_2_0 = lb4 {
    version = "4.2.0";
    md5 = "b179aa5df2d74830bbbf845a82f831da";
  };
  logicblox-4_3_6_3 = lb4 {
    version = "4.3.6.3";
    md5 = "2c2e66ab6209698a6d8e23bca38daa32";
  };
  logicblox-4_3_8_2 = lb4 {
    version = "4.3.8.2";
    md5 = "3dc6dca11008a8fbbffc3a0d650a2161";
  };
}
