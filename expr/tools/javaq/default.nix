{ haskellPackages, fetchgit }:
rec {
  src = fetchgit {
    url = "https://github.com/ucla-pls/jvmhs.git";
    sha256 = "0q08p05zm68mf56vs304r54m15961kjqd4xy3qhwbk4b9a5wckk2";
    rev = "37e069cc02a249225d3cc0fcc3acc3083a1c8682";
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
