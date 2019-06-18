'''This script takes the output of a static analysis
(which does not have bytecode offsets) and the javaq
callsites, and outputs method,offset,target by mapping
declared_targets of the static analysis to those in javaq 
'''

import sys
import csv
from collections import defaultdict

OUTPUT_FILE = sys.argv[1]
JAVAQ_FILE = sys.argv[2]
DOOP_FILE = sys.argv[3]

def read_edges(file):
    javaq_edges = defaultdict(list)
    with open(JAVAQ_FILE) as javaq_fp:
        for row in csv.DictReader(javaq_fp):
            javaq_edges[row["method"], row["declared_target"]].append(row["offset"])
    return dict(javaq_edges)

def main():
    javaq_edges = read_edges(JAVAQ_FILE)

    with open(OUTPUT_FILE, mode='w') as outputf:
        csv_writer = csv.writer(outputf, delimiter=',')

        with open(DOOP_FILE) as doop_fp:
            doop_csv = csv.DictReader(doop_fp, delimiter=',')
            for row in doop_csv:
                edge = (row["method"],row["declared_target"])
                offsets = javaq_edges.get(edge, None)
                order = int(row["order"])
                if offsets:
                    try: 
                        offset = offsets[order]
                    except IndexError:
                        offset = -1
                        print("not enough offsets",row, file=sys.stderr)
                else:
                    offset = 0
                csv_writer.writerow([row["method"],offset,row["target"]])

if __name__ == "__main__":
    main()
