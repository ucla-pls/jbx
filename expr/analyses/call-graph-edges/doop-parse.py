''''''

import sys
import pathlib
import json
import csv

OUTPUT_FILE = sys.argv[1]
JAVAQ_OUTPUT = sys.argv[2]
DOOP_OUTPUT = sys.argv[3]
DOOP_FAKE_ROOT = "doop/FakeRootClass.fakeRootMethod:()V"
INIT_FUNCTIONS = ["<main-thread-init>","<thread-group-init>"]
#Native methods are only used for the following method 
#java/security/AccessController.doPrivileged
NATIVE = "native "
#This is the value set by WALA, so we will be sticking to it
NATIVE_OFFSET = 0

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

#Read javaq output.
#this is not straightforward because each file is a list of json strings
#the file as a whole is not a valid single json string.
#So we first convert it into the right format
def read_javaq_output():
    javaq_output = '{"program" : ['
    with open(JAVAQ_OUTPUT) as fp: 
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
    unique_edges_with_off = {}
    #Read in the JAVAQ output
    javaq_json = read_javaq_output()
    invoke_count = 0
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
                    declared_target_class = instr["class"].replace("/",".")
                    dest_method = remove_args(instr["method"])
                    src_node = src_class_name + "." + src_method
                    declared_target = declared_target_class + "." + dest_method
                    edge = (src_node,declared_target)
                    if edge not in unique_edges_with_off:
                        unique_edges_with_off[edge] = []
                    unique_edges_with_off[edge].append(offset)

    #Read in the Doop outputs
    #note - don't skip first line. There is no header.
    with open(DOOP_OUTPUT) as doop_fp:
        doop_csv = csv.reader(doop_fp, delimiter='\t')
        for row in doop_csv:
            #Compute the src and destination nodes
            dest_node = row[3]
            src_method_call = row[1]
            src_node = src_method_call.split("/")[0]

            #Compute the destination node
            formatted_dest_node = reformat_method(dest_node)
            #Handle the special case of an init function
            if (src_node in INIT_FUNCTIONS):
                output.append([DOOP_FAKE_ROOT,"-1",formatted_dest_node])
            else:
                #Format the source node, and get the declared target
                formatted_src_node = reformat_method(src_node)
                declared_target = src_method_call.split("/")[1]
                #Deal with Native targets
                if NATIVE in declared_target[:7]:
                    offset = NATIVE_OFFSET
                #If not a native target, look for the bytecode offset from javaq
                elif (formatted_src_node,declared_target) in unique_edges_with_off:
                    call_site_order = int(src_method_call.split("/")[2])
                    if call_site_order>=len(unique_edges_with_off[
                            (formatted_src_node,declared_target)]):
                        offset = 0
                    else:
                        offset = unique_edges_with_off[
                        (formatted_src_node,declared_target)][call_site_order]
                else: #Corresponding function not found
                    offset = 0
                output.append([formatted_src_node,offset,formatted_dest_node])
    #Now just write the output
    with open(OUTPUT_FILE, mode='w') as outputf:
        csv_writer = csv.writer(outputf, delimiter=',')
        csv_writer.writerow(["method","offset","target"])
        for line in output:
            csv_writer.writerow(line)


if __name__ == '__main__':
    main()