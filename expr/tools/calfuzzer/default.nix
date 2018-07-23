{stdenv, fetchgit, ant}:
let
calfuzzer = java: stdenv.mkDerivation {
  name = "calfuzzer";
  version = "github";
  src = fetchgit {
    url = "https://github.com/ksen007/calfuzzer";
    rev = "4cab1bc162faf17e950027937071a3c19c318a9b";
    md5 = "6182be956ae3caabfefd3e888c7e0dad";
  };
  # patches = [ ./relative.patch ];
  buildInputs = [ java.jdk ant ];
  installPhase = ''
    mkdir -p $out/shared/java
    ant
    cp lib/* $out/shared/java
    cd classes
    jar cf $out/shared/java/calfuzzer.jar *
  '';
};
in calfuzzer
