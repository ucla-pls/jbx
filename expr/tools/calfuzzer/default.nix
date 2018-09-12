{stdenv, fetchgit, fetchurl, ant, unzip}:
let
calfuzzer = java: stdenv.mkDerivation {
  name = "calfuzzer";
  version = "github";
  src = fetchgit {
    url = "https://github.com/ksen007/calfuzzer";
    rev = "4cab1bc162faf17e950027937071a3c19c318a9b";
    md5 = "6182be956ae3caabfefd3e888c7e0dad";
  };
    sootall = fetchurl { 
      url = "http://www.sable.mcgill.ca/software/sootall-2.4.0.jar";
      sha256 = "0hc3hsn916bgvwaajqamha89b7dbvgj57nbph0hyi76inq5pqvrc";
    };
  patches = [ ./reflection.patch ];
  buildInputs = [ java.jdk ant unzip];
  installPhase = ''
    mkdir -p $out/shared/java
    ls -l lib/
    mkdir soot
    (cd soot; unzip $sootall)
    cp soot/soot-2.4.0/lib/sootclasses-2.4.0.jar lib/sootall-2.3.0.jar
    cp soot/soot-2.4.0/lib/sootclasses-2.4.0.jar lib/soot.jar
    ant cleanall
    ant
    cp lib/* $out/shared/java
    cd classes
    jar cf $out/shared/java/calfuzzer.jar *
  '';
};
in calfuzzer
