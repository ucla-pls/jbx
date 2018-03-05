import csv
import sys

rows = list(csv.reader(sys.stdin))

byname = {}

for row in rows:
    deflt = byname.get(row[0], [])
    deflt += [map(float, row[1:])]
    byname[row[0]] = deflt

w = csv.writer(sys.stdout)
for name in byname:
    sums = map(sum,zip(*byname[name]))
    averages = [s / len(byname[name]) for s in sums]
    lst = [name]
    lst.extend([format(a, '.4g') for a in averages])
    w.writerow(lst)
