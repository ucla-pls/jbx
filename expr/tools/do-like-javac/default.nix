{ stdenv, fetchgit, python, makeWrapper}:
let
  doLikeJavaCBldr =
    { url ? "https://github.com/SRI-CSL/do-like-javac.git"
    , rev ? "74c144da969bbf6f940f19a16e2401dee359cb15"
    , sha256 ? "019chfsndqgks3bv9jjrixm71d60wz7awrbsnqr4wmyn4k3lq4yb"
    , patches ? []
    }:
    stdenv.mkDerivation {
      name = "do-like-javac";
      src = fetchgit {
        inherit url rev sha256;
      };
      buildInputs = [ makeWrapper python ];
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
