
import sys
import os
import csv

def get_deadlocks(f):
    if not os.path.isfile(f): return set()
    with open(f) as locks:
        return set(map(str.strip, locks.readlines()))

program_name = sys.argv[1].rsplit("-",1)[0]
provers = sys.argv[2].split(",")
folders = sys.argv[3:]

repeats = []

total_cycles = set()
total_cmds = set()

for rep_folder in folders:
    reps = {}
    for name in provers:
        f_file = os.path.join(rep_folder, name + ".deadlocks.txt")
        reps[name] = get_deadlocks(f_file);
        total_cmds.add(name)
        total_cycles |= reps[name]

    deadlock = os.path.join(rep_folder, "runtime-deadlock.txt")
    reps["actual"] = { x for x in get_deadlocks(deadlock) }

    repeats.append(reps)

cycles = sorted(total_cycles)
cmds = provers + ["actual"]

no_repeats = len(repeats)

def count_cycles(name):
    return sum(1 for reps in repeats if cycle in reps[name])

writer = csv.DictWriter(sys.stdout, ["00-program"] + cmds + ["cycle"], quoting=csv.QUOTE_NONE, quotechar="|")
writer.writeheader()
for cycle in cycles:
    row = { name: 100 * count_cycles(name) / no_repeats for name in cmds }
    row["00-program"] = program_name
    row["cycle"] = cycle
    writer.writerow(row)
