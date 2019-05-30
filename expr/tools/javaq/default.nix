{ haskellPackages, fetchgit }:
rec {
  src = fetchgit {
    url = "https://github.com/ucla-pls/jvmhs.git";
    sha256 = "0f14l9fzj3x3zjrbyy7v3z6vc5rmk6k6n3zv210l9n9yqmpkxrmz";
    rev = "5e6d7e2989b9713f40bf0b150470f1a3f074da87";
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
