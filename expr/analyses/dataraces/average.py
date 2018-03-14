import csv
import sys

rows = list(csv.reader(sys.stdin))

byname = {}

for row in rows:
    if row[0] == "Program": continue
    deflt = byname.get(row[0], [])
    deflt += [map(float, row[1:])]
    byname[row[0]] = deflt

w = csv.writer(sys.stdout)
w.writerow(["Program","Length", "RVP Length", "Cand", "Dirk", "RVP", "Logging (s)", "RVP Logging (s)", "Solving (s)", "RVP Solving (s)"])
for name in byname:
    sums = map(sum,zip(*byname[name]))
    averages = [s / len(byname[name]) for s in sums]
    lst = [name]
    lst.extend([format(a, '.4g') for a in averages])
    w.writerow(lst)
