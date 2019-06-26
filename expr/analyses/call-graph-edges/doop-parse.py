'''
This script reads in the raw Doop output, converts all methods
to the bytecode format (as opposed to the Java source code 
format used in the raw Doop output) and writes to a csv as
source,offset,dest,declared_target
'''

import sys
import pathlib
import json
import csv

OUTPUT_FILE = sys.argv[1]
DOOP_OUTPUT = sys.argv[2]
MAINCLASS = sys.argv[3]
DOOP_FAKE_ROOT = "<boot>"
INIT_FUNCTIONS = ["<main-thread-init>","<thread-group-init>"]
#Native methods are only used for the following method 
#java/security/AccessController.doPrivileged
NATIVE = "native "
#This is the value set by WALA, so we will be sticking to it
DEFAULT_ORDER = -1
REG_FINALIZE = "<register-finalize "
DEFAULT_TARGET = "target_unavailable"

#formats a type to the correct format
def format_type(type_string):
    formatted_string = ""
    #Add as many '[' as the 
    array_dim = type_string.count("[]")
    formatted_string += "[" * array_dim
    #Remove the array dimensions
    type_string = type_string.replace("[]","")
    if type_string=="byte": formatted_string += "B"
    elif type_string=="char": formatted_string += "C"
    elif type_string=="double": formatted_string += "D"
    elif type_string=="float": formatted_string += "F"
    elif type_string=="int": formatted_string += "I"
    elif type_string=="long": formatted_string += "J"
    elif type_string=="short": formatted_string += "S"
    elif type_string=="boolean": formatted_string += "Z"
    elif type_string=="void": formatted_string += "V"
    else:
        formatted_string += "L" 
        formatted_string += type_string.replace(".","/") + ";"
    return formatted_string

#reformats the method name to the required format
#sample input - <v.V: void methd(int,java.lang.String[])>
#sample output - v/V.methd:(Lint;[Ljava/lang/String;)V
def reformat_method(node):
    #First split into the main parts
    node_split = node.split(" ")
    if len(node_split)<2: print(node_split)
    class_name = node_split[0]
    return_type = node_split[1]
    method_name_with_args = node_split[2]

    #Correct the class name format
    class_name = class_name[1:-1] #drop first (<) and last (:) characters
    class_name = class_name.replace(".","/")
    
    #Correct the method name
    method_name_without_args = method_name_with_args.split("(")[0]

    #Correct the return type format
    return_type = format_type(return_type)

    #Correct the method args
    method_args = method_name_with_args.split("(")[1]
    method_args = method_args[:-2] #remove the last 2 characters ( ')>' )
    method_args_formatted = ""
    if len(method_args)>0: #else there are no args
        method_args_split = method_args.split(",")
        method_args_formatted = ""
        for arg in method_args_split:
            method_args_formatted += format_type(arg)

    #Finally join everything back in the right format
    node_string = (
        class_name
        + "." + method_name_without_args
        + ":(" + method_args_formatted
        + ")" + return_type
    )
    return node_string

#reformats the target to the required format
#sample input - java.lang.Object.finalize
#sample output - java/lang/Object.finalize
def reformat_target(declared_target):
    split = declared_target.split(".")
    class_name = "/".join(split[:-1])
    method_name = split[-1]
    formatted_target = class_name + "." + method_name
    return formatted_target


def main():
    output = []
    #Add an edge from boot to main
    main_class_formatted = MAINCLASS.replace(".","/")
    main_method = main_class_formatted + ".main:([Ljava/lang/String;)V"
    main_method_target = main_class_formatted + ".main"
    output.append([DOOP_FAKE_ROOT,0,main_method,main_method_target])
    #Read in the Doop outputs
    #note - don't skip first line. There is no header.
    with open(DOOP_OUTPUT) as doop_fp:
        doop_csv = csv.reader(doop_fp, delimiter='\t')
        for row in doop_csv:
            #Compute the src and destination nodes
            dest_node = row[3]
            src_method_call = row[1]
            if REG_FINALIZE in src_method_call:
                continue #This corresponds to a new statement. Wala skips these
            else:
                src_node = src_method_call.split("/")[0]
                #Handle the special case of an init function
                if (src_node in INIT_FUNCTIONS):
                    order = DEFAULT_ORDER
                    formatted_src_node = DOOP_FAKE_ROOT
                    formatted_declared_target = DEFAULT_TARGET
                else: #All other cases
                    #Format the source node, and get the declared target
                    formatted_src_node = reformat_method(src_node)
                    declared_target = src_method_call.split("/")[1]
                    formatted_declared_target = reformat_target(declared_target)
                    #Deal with Native targets
                    if NATIVE in declared_target[:7]:
                        order = DEFAULT_ORDER
                    #If not a native target, order will be written
                    else:
                        order = int(src_method_call.split("/")[2])
                #Compute the destination node
                formatted_dest_node = reformat_method(dest_node)
                output.append([
                    formatted_src_node,
                    order,
                    formatted_dest_node,
                    formatted_declared_target
                ])
    
    #Now just write the output
    with open(OUTPUT_FILE, mode='w') as outputf:
        csv_writer = csv.writer(outputf, delimiter=',')
        csv_writer.writerow(["method","order","target","declared_target"])
        for line in output:
            csv_writer.writerow(line)


if __name__ == '__main__':
    main()
