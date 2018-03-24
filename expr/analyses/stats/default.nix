{utils}:
{
  stats = utils.mkAnalysis {
    name = "stats";
    analysis = ''
      find $build/classes -name '*.class' -exec wc -c {} \; > $out/bytecode 
      find $build/src -name '*.java' -exec wc -l {} \; > $out/lines 
    '';
  };
}
