{ stdenv, fetchgit, python, makeWrapper}:
let
  doLikeJavaCBldr =
    { url ? "https://github.com/SRI-CSL/do-like-javac.git"
    , rev ? "94b885c901b29d0a5ae55a2f38512e8825b09503"
    , sha256 ? "0v6b09d2x3ifah9036i0sbxizz9gzk0ndnn234n9555q9qr79zcc"
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
   doLikeJavaCBldr {}
