import csv
from statistics import mean
import sys

fn, name, fsizes, ftimes = sys.argv


size = 0
with open(fsizes) as sizes: 
    size = mean([int(x[0]) for x in csv.reader(sizes)]) 

rtimes = {}
with open(ftimes) as times:
    for x in csv.reader(times):
        rtimes.setdefault(x[0], []).append(float(x[1]))
       
row = { x: format(mean(y), '.4g') for x, y in rtimes.items()}
row["00-name"] = name
row["size"] = size

header = [ "00-name", "size"] + sorted(rtimes)
writer = csv.DictWriter(sys.stdout,  header)
writer.writeheader()
writer.writerow(row)



# byname = {}
# for row in rows:
#     # if row[0] == "Program": continue
#     deflt = byname.get(row[0], [])
#     deflt += [map(float, row[1:])]
#     byname[row[0]] = deflt
# 
# w = csv.writer(sys.stdout)
# # w.writerow(["Program","Length", "RVP Length", "Cand", "Dirk", "RVP", "Logging (s)", "RVP Logging (s)", "Solving (s)", "RVP Solving (s)"])
# for name in byname:
#     sums = map(sum,zip(*byname[name]))
#     averages = [s / len(byname[name]) for s in sums]
#     lst = [name]
#     lst.extend([format(a, '.4g') for a in averages])
#     w.writerow(lst)
