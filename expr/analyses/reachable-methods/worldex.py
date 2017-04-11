
import sys
import os

from subprocess import check_output

build = sys.argv[1]

def readfromfile(*filepath):
    with open(os.path.join(*filename), "r") as f:
        return f.readlines()

classes = readfromfile(build, "info", "classes")

list = []

for cls in classes:
  list += [check_output(["javap","-cp", os.path.join(build, "classes"), cls], universal_newlines=True)]
  
"\n".join(list)

print(list)




