from __future__ import division
#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
The primary functionality of this script is to take a list of filenames, and then
to callculate a the superset, the subset and the revialing 3 numbers. 

subset_not_in / actual / not_in_superset

"""
import sys
import re
import csv
import os


from collections import namedtuple

Timer = namedtuple("Timer", "name real user kernel maxm exitcode")
Result = namedtuple("Result", "times elements")
Stats = namedtuple("Stats", "name elements ucover udist ocover odist time") 

Timer.__add__ = lambda self, other: Timer(
        os.path.commonprefix([self.name, other.name]),
        self.real + other.real,
        self.user + other.user,
        self.kernel + other.kernel,
        max(self.maxm, other.maxm),
        min(self.exitcode, other.exitcode)
    )

def timer (name, real, user, kernel, maxm, exitcode):
    return Timer(
        name, float(real), float(user), float(kernel), 
        int(maxm), int(exitcode)
    )

class Analysis(object):

    def __init__(self, name, sign, resultname):
        self.name = name
        self._sign = sign
        self._resultname = resultname

    def read_result(self, folder):
        resultfile = os.path.join(folder, self._resultname)
        with open(resultfile) as f:
            elements = set(map(str.rstrip, f.readlines()))
        basefile = os.path.join(folder, 'base.csv')
        with open(basefile) as f:
            reader = csv.DictReader(f)
            times = map(lambda r: timer(**r), reader)
        return Result(times, elements); 
    
    def overapproximation(self):
        return self._sign == "+"

    def underapproximation(self):
        return self._sign == "-"

class AnalysisResult(object):
    parser = re.compile(r"""(?P<sign>[+-])
                            (?P<name>[^=]+) 
                            =
                            (?P<folder>.*)
                          """, re.VERBOSE).match
    
    def __init__(self, analysis, folder, result):
        self.analysis = analysis
        self._folder = folder
        self._result = result

        self._time = sum(
           self._result.times[1:], 
           self._result.times[0]
        );

    @classmethod
    def parse(cls, resultname, string):
        """Create an analysis result from a string
        :returns: A new AnalysisResult
        """
        dicts = AnalysisResult.parser(string).groupdict()
        analysis = Analysis(
            dicts["name"],
            dicts["sign"],
            resultname
        )
        return cls(analysis, dicts["folder"], analysis.read_result(dicts["folder"]))

    def errors(self, underaprx, overaprx):
        return (underaprx - self._result.elements, self._result.elements - overaprx)

    def stats(self, underaprx, overaprx):
        hits = len(underaprx & self._result.elements)
        notmisses = len(self._result.elements & overaprx)
        elements = len(self._result.elements)
        return Stats(
            self.analysis.name,
            elements,
            # Did the analysis hit everything in the
            # underapproximation
            hits / len(underaprx) if underaprx else "N/A",
            # Did we not hit everything in the underapproximation
            hits / elements if elements else "N/A", 
            # Were it more precise than the overaproximation 
            notmisses / len(overaprx) if overaprx else "N/A",
            # Did the analysis hit anything not in the
            # overapproximation
            notmisses / elements if elements else "N/A", 
            self._time.real
        ) 

    def overapproximation(self): 
        return self.analysis.overapproximation()
    
    def underapproximation(self): 
        return self.analysis.underapproximation()

    @staticmethod
    def overapproximate(results):
        list_of_elements = map(lambda r: r._result.elements, results)
        if list_of_elements: 
             return set.union(*list_of_elements)
        else: return set()
   
    @staticmethod
    def underapproximate(results):
        list_of_elements = map(lambda r: r._result.elements, results)
        if list_of_elements: 
             return set.union(*list_of_elements)
        else: return set()

def main(): 
    resultfile = sys.argv[1]
    errorfolder = sys.argv[2]
    analyses = sys.argv[3:]
    results = map(lambda arg: AnalysisResult.parse(resultfile, arg), analyses)
    over = AnalysisResult.overapproximate(
        filter(AnalysisResult.overapproximation, results)
    )
    under = AnalysisResult.underapproximate(
        filter(AnalysisResult.underapproximation, results)
    )
   
    fieldnames = ["name", "stats"]
    writer = csv.DictWriter(sys.stdout, fieldnames=Stats._fields)
    writer.writeheader()
    os.mkdir(errorfolder)
    for result in results:
        writer.writerow(result.stats(under, over)._asdict())
        unsound, missing  = result.errors(under, over)
        with open(os.path.join(errorfolder, result.analysis.name + ".txt"), "w") as f:
            for line in sorted(unsound):
                f.write("- " + line + "\n")
            for line in sorted(missing):
                f.write("+ " + line + "\n")

if __name__ == "__main__":
    main()
