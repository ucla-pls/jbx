let pkgs = import ./nixpkgs {};
in {
  benchmarks = import ./benchmarks {
    inherit pkgs;
  };
}
