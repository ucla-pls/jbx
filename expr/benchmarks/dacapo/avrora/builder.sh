#!/usr/bin/env bash
source $stdenv/setup

buildPhase () { 
    cd benchmarks/bms/avrora
    ant all
}

genericBuild

