{ haskellPackages }:
{
  javaq = haskellPackages.callPackage ./jvmhs-develop.nix {
    tasty-discover = "null";
  };
}
