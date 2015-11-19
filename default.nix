let pkgs = import ./nixpkgs {};
in {}: rec {
  inherit (pkgs) runCommand jre7;

  benchmarks = import ./benchmarks {
    inherit pkgs;
  };

  tools = import ./tools {
    inherit pkgs fetchprop;
  };

  analyses = import ./analyses {
    inherit pkgs tools;
  };

  results = import ./results {
    inherit analyses benchmarks env;
  };

  env = import ./environment.nix;

  # This project contains some proprietary file not 
  # distributed with this pkg.
  fetchprop = options: 
    pkgs.fetchurl (options // {
      url = env.ppath + options.url;
    });

}  
