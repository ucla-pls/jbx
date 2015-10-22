source $stdenv/setup

buildPhase () { 
    make
}

installPhase () {
    mkdir jars;
    bash makejar.bash $version

    mkdir -p $out/share/java
    mv jars/* $out/share/java
}

genericBuild
