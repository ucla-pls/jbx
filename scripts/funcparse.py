
from inspect import getfullargspec
import argparse
import functools
import re


def parse_args(func, args = None):
    """
    parse_args parses commandline arguments using
    a function signature.

    """
    if args is None:
        import sys
        args = sys.argv[1:]

    parser = argparse.ArgumentParser(description=func.__doc__)
    pargs = funcparser(parser, func).parse_args(args)
    return partially_resolve(func, vars(pargs))

def collect(specs):
    no_position_args = len(specs.args) - len(specs.defaults)

    for i, name in enumerate(specs.args):
        annotation = specs.annotations[name]
        if not i < no_position_args: 
            default = specs.defaults[i - no_position_args]
        else:
            default = None
        yield (specs.annotations[name], name, default)

def funcparser(parser, func):
    specs = getfullargspec(func)
    
    for annotation, name, default in collect(specs):
        clean = clean_name(name)
        annotation.parse(parser, name, default)

    if specs.varargs:
        parser.add_argument(
            dest='_varargs',
            metavar=specs.varargs,
            nargs='*', 
            type=specs.annotations[specs.varargs]
        )
        
    return parser

def partially_resolve(func, options):
    specs = getfullargspec(func)
    
    args = []
    kwargs = {}
    for annotation, name, default in collect(specs):
        result = annotation.postaction(options[name], options)
        if default is None:
            args.append(result) 
        else:
            kwargs[name] = result

    print(args, kwargs)
    return functools.partial(func,
        *args,
        **kwargs
    )

all_underscores = re.compile('_')
def clean_name(name):
    return all_underscores.sub('-', name)

class SubCommands:

    def __init__(self, *commands, help=None):
        self.commands = { cmd.__name__ : cmd for cmd in commands }
        self.help = help

    def postaction(self, value, options): 
        return partially_resolve(
            self.commands[value],
            options
        )

    def parse(self, parser, name, default):
        subparsers = parser.add_subparsers(
            title = "Sub-commands",
            help = self.help,
            dest = name,
        )

        for name, command in self.commands.items():
            subparser = subparsers.add_parser(
                name,
                help = command.__doc__
            )
            funcparser(subparser, command)


class Arg:
    """An argument.
    """

    def __init__(self, short, help, type = None):
        self.short = short
        self.help = help
        self.type = type

    def postaction(self, value, options):
        return value

    def parse(self, parser, name, default):
        type_ = self.type or type(default)
       
        options = {}
        if type_ is bool:
            options["action"] = "store_false" if default else "store_true"
        else:
            options["type"] = type_

        names = [ "--" + name ]
        if self.short: 
            names += [ self.short ]

        parser.add_argument(
            *names,
            help = "{help} (default: {default})".format(
                help = self.help,
                default = default
            ),
            default = default,
            **options
        )

class Enum: 

    def __init__(self, enum, help):
        self.enum = enum
        self.help = help

    def postaction(self, value, options):
        return value

    def parse(self, parser, name, default):
        if default:
            grp = parser.add_mutually_exclusive_group()
            for ename in self.enum:
                grp.add_argument(
                    "--" + ename, 
                    action ='store_const', 
                    const = ename,
                    dest = name
                )
            defaults = {}
            defaults[name] = default
            parser.set_defaults(**defaults)

        else:
            parser.add_argument(name,
                choices = self.enum,
                default = default,
                help = "{help} (default: {default})".format(
                    help = self.help,
                    default = default
                )
            )

