'''
This file reads the javaq json output and 
outputs a csv file of method,offset,declared_target
for each callsite
'''

import sys
import pathlib
import json
import csv

def remove_args(method):
    """Removes the arguments and return type from a method in bytecode format
    sample input = methd:(Lint;[Ljava/lang/String;)V
    sample output = methd"""
    return method.split(":")[0]

def main():
    writer = csv.writer(sys.stdout, delimiter=",")
    writer.writerow(["method","offset","declared_target"])
    callsites = []
    for src_class_obj in (json.loads(line) for line in sys.stdin):
        src_class_name = src_class_obj['name']
        methods = src_class_obj['methods']
        for src_method, method in methods.items():
            code = method.get('code', False)
            if not code: continue
            byte_code = code.get('byte_code', False)
            if not byte_code: continue
            for instr in byte_code:
                if instr["opc"] == "invoke":
                    offset = instr["off"]
                    # if class is not in instruction, the reason is that 
                    # it is a dynamic call target as described here 
                    # https://docs.oracle.com/javase/specs/jvms/se11/html/jvms-4.html#jvms-4.4.10
                    if "class" not in instr:
                        print(src_class_name, src_method, instr["method"], file=sys.stderr)
                        continue
                    src_node = src_class_name + "." + src_method
                    declared_target_class = instr["class"]
                    dest_method = remove_args(instr["method"])
                    declared_target = declared_target_class + "." + dest_method
                    writer.writerow([src_node,offset,declared_target])

if __name__ == '__main__':
    main()
