{ callPackage, utils }:
rec {
  mini_corpus = callPackage ./mini_corpus {};

  all = builtins.foldl' (all: bm: all ++ bm.all) [] [
    mini_corpus
  ];
}
