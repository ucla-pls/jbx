# A command line based tool for interacting with jbx benchmarks in mongodb
import pymongo

def buildscripts_info(benchmarks):
    """ Prints the % of benchmarks with and without build scripts """

    total = benchmarks.find().count()
    with_build = benchmarks.find(
        {
            "buildwith":
            {
                "$in": ["ant", "maven", "gradle"]
            }
        }).count()
    without_build = total - with_build
   
    print("# total benchmarks: %d" % total)
    print("# benchmarks with build script: %d" % with_build)
    print("# benchmarks without build script: %d" % without_build)
    print("%% benchmarks with build script: %f\n" % (with_build/total))


def benchmarks_info(benchmarks):
    """ 
    Prints % of benchmarks with classes and main classes extracted from the
    flattening 
    """

    total = benchmarks.find().count()
    n = benchmarks.find({"benchmarks": {"$size": 0}}).count()
    no_classes = benchmarks.find({"classes": {"$size": 0}}).count()
    no_main = benchmarks.find({"mainclasses": {"$size": 0}}).count()

    print("# total benchmarks: %d" % total)
    print("%% benchmarks with benchmarks: %f" % ((total - n)/total))
    print("%% benchmarks with classes: %f" % ((total-no_classes)/total))
    print("%% benchmarks with main: %f\n" % ((total-no_main)/total))


def print_benchmarks(cursor):
    """ Prints the name of each benchmark in input cursor """

    for doc in cursor:
        print(doc['name'])
    
# This function is just an example of how to parallelize queries
def parallel_scan(benchmarks, n_threads=2):
    """ Performs parallel scan over all documents in the collection """
    import threading

    cursors = benchmarks.parallel_scan(n_threads)
    threads = [
        threading.Thread(target=print_benchmarks, args=(cursor,))
        for cursor in cursors]

    for thread in threads:
        thread.start()

    for thread in threads:
        thread.join()


if __name__ == '__main__':
    # Establish connection to mongo server
    client  = pymongo.MongoClient('localhost', 27017)
    jbx_db  = client['jbx']
    benchmarks = jbx_db['benchmarks'] 

    buildscripts_info(benchmarks)
    benchmarks_info(benchmarks)
