{ souffle
, gradle
, fetchgit
, gnumake
, cmake
, zlib
, sqlite
, glibcLocales
, ncurses
, openjdk
, stdenv
, fetchurl
, libtool
, makeWrapper
}:
let buildDrv = 
  stdenv.mkDerivation rec {
     name = "doop-${version}";
     version = "3.3.1";
     src = fetchgit {
       url = "https://bitbucket.org/yanniss/doop.git";
       rev = "c34adb68a1ce588e943ff35a0f8395d1e8fb251b";
       sha256 = "01bkj1w4h2msqfi0d3ar5jkjzsjf4azdl962j0mdd595abk25nd6";
       branchName = "master";
     };
  
     buildInputs = [
       gradle
       gnumake
       souffle
       cmake
       zlib
       sqlite
       glibcLocales
       ncurses
       libtool
       openjdk
       makeWrapper
     ];
  
     phases = [ "unpackPhase" "patchPhase" "buildPhase" "installPhase" ];
  
     patches = [ ./nobash.patch ];
  
     buildPhase = '' 
      gradle -g /tmp distTar
      tar -xf build/distributions/${name}.tar
      patchShebangs ./${name}
      cd ${name}
     '';
  
     installPhase = ''
       mkdir -p $out
       cp -r bin/ $out/bin
       mkdir -p $out/share/java
       cp -r lib/* $out/share/java
       cp -r logic $out/logic
       cp -r souffle-logic $out/souffle-logic
       ln -s $out/share/java $out/lib
       mv $out/bin/doop $out/bin/doop_unwrapped
   
       makeWrapper $out/bin/doop_unwrapped $out/bin/doop \
         --set DOOP_HOME $out/ \
         --prefix PATH : ${souffle}/bin
     '';
  };
in {
doop-3_3_1 =
  stdenv.mkDerivation rec {
     name = "doop-${version}";
     version = "3.3.1";
     src = fetchurl {
       url = "http://tupai.cs.ucla.edu/${name}.tar";
       sha256 = "0v87zg7rrhr52kk7a306chhrcn1nk8zqib18pxxjhm098mvzkdi6";
     };
  
     phases = [ "unpackPhase" "installPhase" ];
  
     buildInputs = [
       souffle
       glibcLocales
       makeWrapper
     ];
  
     installPhase = ''
       patchShebangs .
       mkdir -p $out
       cp -r bin/ $out/bin
       mkdir -p $out/share/java
       cp -r lib/* $out/share/java
       cp -r logic $out/logic
       cp -r souffle-logic $out/souffle-logic
       ln -s $out/share/java $out/lib
       mv $out/bin/doop $out/bin/doop_unwrapped
   
       makeWrapper $out/bin/doop_unwrapped $out/bin/doop \
         --set DOOP_HOME $out/ \
         --set GRADLE_OPTS "--offline" \
         --prefix PATH : ${souffle}/bin
     '';
  };

doop-4_10_11 =
  stdenv.mkDerivation rec {
     name = "doop-${version}";
     version = "4.10.11";
     src = fetchurl {
       url = "http://tupai.cs.ucla.edu/${name}.tar";
       sha256 = "0mw4chsfqdz57d1vgl89ybs5fpgbqj70ihi45r73q0vlrvw80zpx";
     };
     
     benchmarks = fetchgit { 
	url = "https://bitbucket.org/yanniss/doop-benchmarks.git";
        rev = "5e0b6a8768215d50c21ba27ace72343d62174c7b";
        branchName = "master";
        sha256 = "0chg4nvwpha8v2p20zpyainm64686cdkwb78dh781xf6higdvvdp";
     };
  
     phases = [ "unpackPhase" "installPhase" ];
  
     buildInputs = [
       souffle
       glibcLocales
       makeWrapper
     ];
  
     installPhase = ''
       patchShebangs .
       mkdir -p $out
       cp -r bin/ $out/bin
       mkdir -p $out/share/java
       cp -r lib/* $out/share/java
       cp -r logic $out/logic
       cp -r souffle-logic $out/souffle-logic
       ln -s $out/share/java $out/lib
       mv $out/bin/doop $out/bin/doop_unwrapped

       ln -s $benchmarks $out/platforms
       ln -s ${souffle} $out/souffle
   
       makeWrapper $out/bin/doop_unwrapped $out/bin/doop \
         --set DOOP_HOME $out/ \
         --set GRADLE_OPTS "--offline" \
         --set DOOP_PLATFORMS_LIB $benchmarks \
         --prefix PATH : ${souffle}/bin
     '';
  };
}
