{ nixpkgs ? import <nixpkgs> {} }:
let
  pkgs = nixpkgs.pkgs;
  souffle = pkgs.callPackage ./souffle.nix {};
in pkgs.callPackage ./default.nix { souffle = souffle; }
