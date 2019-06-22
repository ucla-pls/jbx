'''Combines the various callgraphs into 1 file'''
import sys
import csv
import pathlib

BENCHMARK_FOLDER = sys.argv[1] 
GRAPH_FILENAME = sys.argv[2] 
OUTPUT_FILE = sys.argv[3] 

#holds all the output_rows of the combination output file
#key = (method,offset,target)
#value = list of analyses which predict the edge to exist
output_rows = {}
analyses_names = []

#Loop through the folder names to get the analysis names
benchmarks_folder = pathlib.Path(BENCHMARK_FOLDER)
for analysis in benchmarks_folder.iterdir():
    if not analysis.is_dir(): #skip non-directories
        continue
    analyses_names.append(analysis.name)

#Loop through all the file names and read the output_rows into joint_dataset
for analysis in benchmarks_folder.iterdir():
    if not analysis.is_dir(): #skip non-directories
        continue

    with open(analysis / GRAPH_FILENAME, 'r') as readfp:
        csv_reader = csv.reader(readfp, delimiter=',')
        for row in csv_reader:
            method = row[0]
            offset = row[1]
            target = row[2]

            if (method,offset,target) not in output_rows:
                output_rows[(method,offset,target)] = set()
            output_rows[(method,offset,target)].add(analysis.name)

#Write it all to a common file
with open(OUTPUT_FILE, mode='w') as csv_file:
    fieldnames = ["method","offset","target"] + analyses_names
    writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
    writer.writeheader()
    for (method,offset,target),analyses_list in output_rows.items():
        row = {}
        row["method"] = method
        row["offset"] = offset
        row["target"] = target
        for analysis in analyses_names:
            if analysis in analyses_list:
                row[analysis] = 1
            else:
                row[analysis] = 0
        writer.writerow(row)
