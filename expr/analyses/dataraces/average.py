import csv
import sys
import statistics

rows = list(csv.reader(sys.stdin))

byname = {}

for row in rows:
    if row[0] == "Program": continue
    deflt = byname.get(row[0], [])
    deflt += [map(float, row[1:])]
    byname[row[0]] = deflt

w = csv.writer(sys.stdout)
titles = [ "Length", "RVP Length", "Cand", "Dirk", "RVP", "Logging (s)", "RVP Logging (s)", "Solving (s)", "RVP Solving (s)"]
w.writerow(["Program"] + sum(([t + " (mean)", t + " (SD)"] for t in titles), []) )
for name in byname:
    lst = [name]
    for col in zip(*byname[name]): 
        mean = statistics.mean(col)
        try: 
            stdev = statistics.stdev(col)
        except statistics.StatisticsError: 
            stdev = 0
        lst.extend([format(mean, '.4g'), format(stdev, '.4g')])
    w.writerow(lst)
