import csv
import os
import sys

result = sys.argv[1]

dct = {}
with open(os.path.join(result, "times.csv")) as fp:
    r = list(csv.reader(fp))
    for l in r[1:]:
        x = l[0].split("+",1)
        dct["name"] = x[1].split("$")[0]
        dct[x[0]] = l[1]
with open(os.path.join(result, "history.size.txt")) as fp:
    dct["history"] = int(fp.read())
    
with open(os.path.join(result, "history.count.txt")) as fp:
    sync,acq,req,rel,fork,join,rds,wrts,bgns,ends,branch,enters = list(csv.reader(fp))[0]
    dct["threads"] = int(bgns)+1
    dct["lock-events"] = int(acq)+int(req)+int(rel)
    dct["rw-events"] = int(rds)+int(wrts)
    dct["enter-events"] = int(enters)
    dct["branch-events"] = int(branch)

w = csv.DictWriter(sys.stdout, ["name", "threads", "run", "wiretap", "wiretap-deadlock","lock-events", "rw-events", "enter-events", "branch-events", "history"])
w.writerow(dct)
