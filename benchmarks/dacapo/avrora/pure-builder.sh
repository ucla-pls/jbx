source $stdenv/setup

buildPhase () { 
    make
}

genericBuild
