'''Combines the various callgraphs into 1 file'''
import sys
import csv
from pathlib import Path
from collections import defaultdict

def main():
    BENCHMARK_FOLDER = sys.argv[1] 
    DYN_ANALYSIS = sys.argv[2] 
    OUTPUT_FILE = sys.argv[3] 

    output_rows = defaultdict(set)
    benchmarks_folder = Path(BENCHMARK_FOLDER)
    analysis_names = ["wiretap"]

    for analysis in sorted(benchmarks_folder.iterdir()):
        if not analysis.is_dir():
            continue
        
        name, _ = analysis.name.rsplit("-", 1)
        analysis_names.append(name + "-direct")
        analysis_names.append(name + "-indirect")
        
        with open(analysis / "upper", 'r') as readfp:
            csv_reader = csv.reader(readfp, delimiter=',')
            for method, offset, target, direct in csv_reader:
                output_rows[method, offset, target].add(name + ("-direct" if
                    direct else "-indirect"))
        
    with open(Path(DYN_ANALYSIS) / "lower", 'r') as readfp:
        csv_reader = csv.reader(readfp, delimiter=',')
        for method, offset, target, direct in csv_reader:
            output_rows[method, offset, target].add("wiretap")

    with open(OUTPUT_FILE, mode='w') as csv_file:
        fieldnames = ["method","offset","target"] + analysis_names
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for (method,offset,target),analyses_list in output_rows.items():
            row = {"method": method, "offset": offset, "target": target }
            for analysis in analysis_names:
                row[analysis] = 1 if analysis in analyses_list else 0
            writer.writerow(row)


if __name__ == "__main__":
    main()
