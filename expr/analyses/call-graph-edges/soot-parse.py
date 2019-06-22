''''''

import sys
import pathlib
import json
import csv

OUTPUT_FILE = sys.argv[1]
SOOT_OUTPUT = sys.argv[2]
#DOOP_FAKE_ROOT = "soot/FakeRootClass.fakeRootMethod:()V"
#INIT_FUNCTIONS = ["<main-thread-init>","<thread-group-init>"]
#Native methods are only used for the following method 
#java/security/AccessController.doPrivileged
#NATIVE = "native "
#This is the value set by WALA, so we will be sticking to it
DEFAULT_ORDER = -1
#REG_FINALIZE = "<register-finalize "
DEFAULT_TARGET = "target_unavailable"
NULL_ENTRY = "null"

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
    #Soot/Petablox outputs orders as the sequence of invoke instructions
    #for a 'src_node'
    #However doop outputs orders as the sequence of invoke instructions
    #for a 'src_node'-'declared_target' pair, and we are going to move
    #things to the doop format through this new_orders
    new_orders = {}
    #Read in the Soot outputs
    #note - don't skip first line. There is no header.
    with open(SOOT_OUTPUT) as soot_fp:
        soot_csv = csv.reader(soot_fp, delimiter=';')
        for row in soot_csv:
            #Compute the src and destination nodes
            if len(row)<4: #Skip these
                continue
            src_node = row[0]
            old_order = row[1]
            dest_node = row[2]
            declared_target = row[3]
            if dest_node == NULL_ENTRY: #skip null entries
                continue
            #Format the entries according to the required format
            formatted_src_node = reformat_method(src_node)
            formatted_declared_target = reformat_target(declared_target)
            formatted_dest_node = reformat_method(dest_node)
            output.append([
                formatted_src_node,
                old_order,
                formatted_dest_node,
                formatted_declared_target
            ])

            #Record in the new_orders{} dictionary for fixing the orders at a later point.
            if (formatted_src_node,formatted_declared_target) not in new_orders:
                new_orders[(formatted_src_node,formatted_declared_target)] = []
            new_orders[(formatted_src_node,formatted_declared_target)].append(int(old_order))
    
    #Keep all the orders in a sorted list
    for entry in new_orders:
        new_orders[entry].sort()

    #print(new_orders)
    #Now just fix all the orders
    for entry in output:
        new_order_list = new_orders[entry[0],entry[3]]
        new_order_value = new_order_list.index(int(entry[1]))
        #The required entry is the index of the 'old_order' entry in the
        #corresponding sorted 'new_orders' list
        entry[1] = new_order_value

    #Now just write the output
    with open(OUTPUT_FILE, mode='w') as outputf:
        csv_writer = csv.writer(outputf, delimiter=',')
        csv_writer.writerow(["method","order","target","declared_target"])
        for line in output:
            csv_writer.writerow(line)


if __name__ == '__main__':
    main()
