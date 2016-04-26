let nixpkgs = import ./nixpkgs {};
    env = import ../environment.nix;

    # This project contains some proprietary file not 
    # distributed with this pkg.
    fetchprop = options: 
      pkgs.fetchurl (options // {
        url = env.ppath + options.url;
      });

    tools = nixpkgs.callPackage ./tools { inherit fetchprop; };
    
    # Update the packages with our tools
    pkgs = nixpkgs // tools // { 
      inherit utils; 
      callPackage = pkgs.lib.callPackageWith pkgs;
      java = java;
    }; 
    
    utils = pkgs.callPackage ./utils {};
    java = import ./java { inherit pkgs; };

in {}: rec {
  inherit tools utils java ;
  benchmarks = pkgs.callPackage ./benchmarks {};
  analyses = pkgs.callPackage ./analyses {};
  results = pkgs.callPackage ./results { inherit benchmarks analyses env;};
  transformers = pkgs.callPackage ./tranformers {};
}  
