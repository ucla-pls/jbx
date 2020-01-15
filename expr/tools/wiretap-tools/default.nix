{ haskell, haskellPackages }:
{
  wiretap-tools = haskell.lib.dontCheck (haskellPackages.callPackage ./wiretap-master.nix {});
}
