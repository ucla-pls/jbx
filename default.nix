let pkgs = import ./nixpkgs {};
in {}: {
  inherit (pkgs) runCommand jre7;
  benchmarks = import ./benchmarks {
    inherit pkgs;
  };
  tools = import ./tools {
    inherit pkgs;
  };
}
