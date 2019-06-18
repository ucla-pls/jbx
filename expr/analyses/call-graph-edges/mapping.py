'''This script takes the output of a static analysis
(which does not have bytecode offsets) and the javaq
callsites, and outputs method,offset,target by mapping
declared_targets of the static analysis to those in javaq 
'''

import sys
import csv

OUTPUT_FILE = sys.argv[1]
JAVAQ_FILE = sys.argv[2]
DOOP_FILE = sys.argv[3]

javaq_edges = {}
insufficient_count = 0
missing_count = 0
with open(JAVAQ_FILE) as javaq_fp:
  javaq_csv = csv.DictReader(javaq_fp)
  for row in javaq_csv:
    edge = (row["method"],row["declared_target"])
    if edge not in javaq_edges:
    	javaq_edges[edge] = []
    javaq_edges[edge].append(row["offset"])

with open(OUTPUT_FILE, mode='w') as outputf:
  csv_writer = csv.writer(outputf, delimiter=',')
  csv_writer.writerow(["method","offset","target"])
  
  with open(DOOP_FILE) as doop_fp:
    doop_csv = csv.DictReader(doop_fp, delimiter=',')
    for row in doop_csv:
      edge = (row["method"],row["declared_target"])
      order = int(row["order"])
      if edge in javaq_edges:
        if order < len(javaq_edges[edge]):
          offset = javaq_edges[edge][order]
        else:
          offset = -1
          print("not enough offsets",row)
          #if "avrora" in row["method"]:
          #  print(row)
        csv_writer.writerow([row["method"],offset,row["target"]])
      else:
        csv_writer.writerow([row["method"],0,row["target"]])
        #if "avrora" in row["method"]:
        #    print(row)


        