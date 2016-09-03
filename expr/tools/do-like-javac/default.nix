{ stdenv, fetchgit, python, makeWrapper}:
let
  doLikeJavaCBldr =
    { url ? "https://github.com/SRI-CSL/do-like-javac.git"
    , rev ? "74c144da969bbf6f940f19a16e2401dee359cb15"
    , sha256 ? "1z5lb4d3xx3vhbyp5k3hcysyxq5qpcqcm6a5zhfz4ns9l0azv37n"
    , patches ? []
    }:
    stdenv.mkDerivation {
      name = "do-like-javac";
      src = fetchgit {
        inherit url rev sha256;
      };
      buildInputs = [ makeWrapper ];
      installPhase = ''
        mkdir -p $out/bin/
        cp -r dljc do_like_javac $out
        makeWrapper $out/dljc $out/bin/dljc \
          --prefix PATH ":" ${python}/bin
      '';
      inherit patches;
    };
 in
   doLikeJavaCBldr { patches = [ ./json-fix.patch ]; }
