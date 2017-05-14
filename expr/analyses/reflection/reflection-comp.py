import os

def get_lines(path, filename):
    try:
        with open(os.path.join(path, filename), "r") as f:
            return set(map(lambda x: x.strip(), f.readlines()))
    except:
        return set()

outdir = os.environ["out"]
benchmark = os.environ["name"]
reflection_callers = lambda file: get_lines(os.environ["reflection_callers"], file)
reachable_methods = lambda file: get_lines(os.environ["reachable_methods"], file)

with open(os.path.join(outdir, "upper"), "w") as f:
    if reflection_callers("upper").isdisjoint(reachable_methods("upper")):
        print("%s does not utilize reflection" % benchmark)
    else:
        print("%s may utilize reflection" % benchmark)
        print("yes", file=f)
    # Print no unconditionally for overapproximation since we cannot determine
    # whether method utilizes reflection, even if the intersection of
    # reflection_callers and reachable_methods is not disjoint
    print("no", file=f)

with open(os.path.join(outdir, "lower"), "w") as f:
    if not reflection_callers("lower").isdisjoint(reachable_methods("lower")):
        print("yes", file=f)
