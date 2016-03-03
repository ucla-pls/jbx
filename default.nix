let nixpkgs = import ./nixpkgs {};
    env = import ./environment.nix;

    # This project contains some proprietary file not 
    # distributed with this pkg.
    fetchprop = options: 
      pkgs.fetchurl (options // {
        url = env.ppath + options.url;
      });

    tools = nixpkgs.callPackage ./tools { inherit fetchprop; };
    
    # Update the packages with our tools
    pkgs = nixpkgs // tools // { inherit utils; 
      callPackage = pkgs.lib.callPackageWith pkgs;
    }; 
    
    utils = pkgs.callPackage ./utils {};

in {}: rec {
  inherit tools utils;
  benchmarks = pkgs.callPackage ./benchmarks {};
  analyses = pkgs.callPackage ./analyses {};

  results = import ./results {
    inherit analyses benchmarks env java tools;
    inherit (pkgs) lib;
  };

  java = import ./java {
    inherit pkgs;
  };
}  
