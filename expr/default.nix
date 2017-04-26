{ env ? import ../environment.nix, nixpkgs ? import ../nixpkgs {}}:
let
  tools = nixpkgs.callPackage ./tools { inherit (utils) fetchprop; };

  # Update the packages with our tools
  pkgs = nixpkgs // tools // {
    inherit utils;
    callPackage = pkgs.lib.callPackageWith pkgs;
    java = java;
  };

  utils = pkgs.callPackage ./utils { inherit env; };
  java = import ./java { inherit pkgs; };
in rec {
    inherit tools utils java;
    inherit pkgs;
    inherit env;
    benchmarks = pkgs.callPackage ./benchmarks {};
    analyses = pkgs.callPackage ./analyses {};
    transformers = pkgs.callPackage ./transformers {};
    targets = pkgs.callPackage ./targets {
      inherit benchmarks analyses env transformers;
    };
  }
