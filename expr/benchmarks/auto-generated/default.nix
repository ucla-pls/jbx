{ callPackage, utils }:
rec {
  integration-test = callPackage ./integration-test {};
  mini_corpus = callPackage ./mini_corpus {};

  all = builtins.foldl' (all: bm: all ++ bm.all) [] [
    integration-test
    mini_corpus
  ];
}
