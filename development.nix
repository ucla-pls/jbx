{pkgs ? import ./nixpkgs {}}:
rec {
  python = 
   pkgs.python35.withPackages (ps: 
     [ ps.pymongo
     ]
   );
  all = with pkgs; buildEnv {
    name = "development-tools";
    paths = [
      python 
      nix-prefetch-scripts
      jq
    ];
  };
}
