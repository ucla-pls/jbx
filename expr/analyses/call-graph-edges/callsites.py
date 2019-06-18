'''
This file reads the javaq json output and 
outputs a csv file of method,offset,declared_target
for each callsite
'''

import sys
import pathlib
import json
import csv

OUTPUT_FILE = sys.argv[1]
JAVAQ_OUTPUT = sys.argv[2]

#Read javaq output.
#this is not straightforward because each file is a list of json strings
#the file as a whole is not a valid single json string.
#So we first convert it into the right format
def read_javaq_output():
    javaq_output = '{"program" : ['
    with open(JAVAQ_OUTPUT, encoding='utf-8') as fp: 
        line = fp.readline()
        javaq_output += "\n" + line
        while line:
           javaq_output += "," + "\n" + line
           line = fp.readline()
    javaq_output += "]}"
    return json.loads(javaq_output)

#Removes the arguments and return type from a method in bytecode format
#sample input = methd:(Lint;[Ljava/lang/String;)V
#sample output = methd
def remove_args(method):
    return method.split(":")[0]

def main():
    output = []
    callsites = []
    #Read in the JAVAQ output
    javaq_json = read_javaq_output()
    #Read in all unique edges and their possible bytecode offsets from Javaq
    for src_class_obj in javaq_json['program']:
        src_class_name = src_class_obj['name']
        methods = src_class_obj['methods']
        for src_method in methods:
            #Skip methods with no bytecode
            if src_method == None: continue
            if ('code' not in methods[src_method] 
                    or methods[src_method]['code']==None): 
                continue
            if ('byte_code' not in methods[src_method]['code']
                    or methods[src_method]['code']['byte_code'])==None: 
                continue
            #Else iterate through the invoke instructions
            for instr in methods[src_method]['code']['byte_code']:
                if instr["opc"] == "invoke":
                    offset = instr["off"]
                    #if class is not in instruction, the reason is that 
                    #it is a dynamic call target as described here 
                    #https://docs.oracle.com/javase/specs/jvms/se11/html/jvms-4.html#jvms-4.4.10
                    if "class" not in instr:
                        print(src_class_name)
                        print(src_method)
                        print(instr["method"])
                        print()
                        continue
                    src_node = src_class_name + "." + src_method
                    declared_target_class = instr["class"]
                    dest_method = remove_args(instr["method"])
                    declared_target = declared_target_class + "." + dest_method
                    callsites.append([src_node,offset,declared_target])

    #Now just write the output
    with open(OUTPUT_FILE, mode='w') as outputf:
        csv_writer = csv.writer(outputf, delimiter=',')
        csv_writer.writerow(["method","offset","declared_target"])
        for line in callsites:
            csv_writer.writerow(line)

if __name__ == '__main__':
    main()
