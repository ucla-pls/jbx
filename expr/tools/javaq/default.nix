{ haskellPackages, fetchgit }:
rec {
  src = fetchgit {
    url = "https://github.com/ucla-pls/jvmhs.git";
    sha256 = "0mqm4jmy2gy3qh3j068igd4gzfag0mbxadbpzjdnzjmpqbs9y50z";
    rev = "fdfad2e4211828c26150a048e0ac33a304ca0416";
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
