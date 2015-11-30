let gpkgs = import ./nixpkgs {};
    env = import ./environment.nix;

    # This project contains some proprietary file not 
    # distributed with this pkg.
    fetchprop = options: 
      gpkgs.fetchurl (options // {
        url = env.ppath + options.url;
      });
    
    tools = import ./tools { pkgs = gpkgs; inherit fetchprop; };
    
    # Update the packages with our tools
    pkgs = gpkgs // tools; 
in {}: rec {
  inherit (pkgs) runCommand jre7 jre6 jre5 python;

  inherit tools;

  benchmarks = import ./benchmarks {
    inherit pkgs java;
  };

  analyses = import ./analyses {
    inherit pkgs tools;
  };

  results = import ./results {
    inherit analyses benchmarks env java;
    inherit (pkgs) lib;
  };

  java = import ./java {
    inherit pkgs;
  };
}  
