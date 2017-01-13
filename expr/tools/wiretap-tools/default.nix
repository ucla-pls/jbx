{ haskellPackages }:
{
  wiretap-tools = haskellPackages.callPackage ./wiretap-develop.nix {};
}
