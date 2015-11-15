let pkgs = import ./nixpkgs {};
in {}: rec {
  inherit (pkgs) runCommand jre7;

  benchmarks = import ./benchmarks {
    inherit pkgs;
  };

  tools = import ./tools {
    inherit pkgs;
  };

  analyses = import ./analyses {
    inherit pkgs tools;
  };

  results = import ./results {
    inherit analyses benchmarks;
  };


}  
