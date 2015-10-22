let pkgs = import ./nixpkgs {};
in {
  benchmarks = import ./benchmarks {
    inherit pkgs;
  };
  tools = import ./tools {
    inherit pkgs;
  };
}
