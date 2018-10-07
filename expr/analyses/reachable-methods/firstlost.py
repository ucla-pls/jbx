#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
The goal of this code is to find the firstlost, as the result of the 
wiretap analyser.
"""

import sys
import shutil
import os.path as path
import glob 

unsoundnessfolder = sys.argv[1]

methods_txt = path.join(unsoundnessfolder, "methods.txt")

try: 
    with open(methods_txt, "r") as mf:
        methods = []
        for line in mf:
            methods.append(line.strip().split(" "))
    for sign, name in methods:
        if sign == "-": break
    else: 
        raise Exception("no methods in folder")
    
    firstlost = name

    for stack in glob.glob(path.join(unsoundnessfolder, "*.stack")):
        try: 
            with open(stack, "r") as sf: 
                stackframe = [ line.strip().split(" ") for line in sf ]
            if stackframe[0][0] == firstlost:
                break
        except Exception as e:
            print(e)
            continue
    else:
        raise Exception("No good stack found for firstlost")

    shutil.copyfile(stack, "firstlost.stack")
    try: 
        shutil.copyfile(path.splitext(stack)[0] + ".log", "firstlost.log")
    except Exception as e:
        print("no firstlost log")

except Exception as e:
    print(e)
    pass

