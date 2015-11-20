{stdenv, fetchprop, coreutils }:
stdenv.mkDerivation {
  name = "jre6";
  src = fetchprop {
    url = "jre-6u45-linux-x64.bin";
    md5 = "4a4569126f05f525f48bacf761f7185c";
  };
  buildInputs = [ coreutils ];
  phases = [ "buildPhase" "installPhase" "fixupPhase" ];
  buildPhase = ''
    tail -n +146 "$src" > install

    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      "install"
    chmod +x install
    ./install
  '';

  installPhase = ''
    mv jre1.6.0_45 $out
  '';

  postFixup = ''
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      "$out/bin/java"
  '';
}
