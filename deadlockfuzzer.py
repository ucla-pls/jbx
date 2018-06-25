import glob
import csv
import sys
import os

writer = csv.DictWriter(sys.stdout, ["name", "time", "deadlocks"])
writer.writeheader()

for f in glob.glob(sys.argv[1] + "/results/*"): 
    name = os.path.basename(f)
    with open(os.path.join(f, "times.csv")) as fp: 
        reader = list(csv.DictReader(fp))
        time = sum(float(l["real"]) for l in reader)
        fail = any("igoodlock" in l["name"] and int(l["exitcode"]) == 1 for l in reader) 

    with open(os.path.join(f, "stderr")) as fp:
        st = fp.read()
        count = st.count("Real Deadlock Detected")
    writer.writerow({"name": name, "time": "{:0.2f}".format(time), "deadlocks": "FAIL" if fail else count})
