import csv
import sys

dct = {}
with open(sys.argv[1]) as fp:
    r = list(csv.reader(fp))
    for l in r[1:]:
        x = l[0].split("+",1)
        dct["name"] = x[1].split("$")[0]
        dct[x[0]] = l[1]

w = csv.DictWriter(sys.stdout, ["name", "run", "wiretap", "wiretap-deadlock"])
w.writerow(dct)
