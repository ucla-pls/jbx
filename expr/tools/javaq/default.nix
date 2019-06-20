{ haskellPackages, fetchgit }:
rec {
  src = fetchgit {
    url = "https://github.com/ucla-pls/jvmhs.git";
    sha256 = "1id6qzmly0783lr5shz9j7r90ivfn2fvww9331cvrzdxcr56bs5g";
    rev = "12cb4e7a97a509e4494a560f699bf1bb1127b34f";
  };

  javaq = haskellPackages.callPackage ./javaq-develop.nix {
    inherit jvmhs src;
  };
  jvmhs = haskellPackages.callPackage ./jvmhs-develop.nix {
    inherit jvm-binary src;
  };
  jvm-binary = haskellPackages.callPackage ./jvm-binary-master.nix {
  };
}
