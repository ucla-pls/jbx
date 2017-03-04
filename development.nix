{pkgs ? import ./nixpkgs {}}:
rec {
  python = 
   pkgs.python35.withPackages (ps:
     with ps;
     [ pymongo
       (mongoengine ps)
       six
     ]
   );
  mongoengine = ps:
    ps.buildPythonPackage rec {
      name = "mongoengine-0.11.0";

      src = pkgs.fetchurl {
        url = "mirror://pypi/m/mongoengine/${name}.tar.gz";
        sha256 = "1ff6q0brknahh209kfa237w2a6dv141fykqppfr3ppi65l6jnlrr";
      };

      buildInputs = with ps; [ pymongo sphinx six ];
      doCheck = false;

      meta = {
        homepage = "https://github.com/MongoEngine/mongoengine";
        # license = licenses.mit;
        description = "MongoEngine is a Python Object-Document Mapper for working with MongoDB";
      };
    };

  all = with pkgs; buildEnv {
    name = "development-tools";
    paths = [
      python
      nix-prefetch-scripts
      jq
    ];
  };
}
