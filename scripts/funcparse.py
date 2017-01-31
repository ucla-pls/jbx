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
    no_position_args = (
        len(specs.args) -
        (len(specs.defaults) if specs.defaults else 0)
    )

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
            dest='*' + func.__name__,
            metavar=specs.varargs,
            nargs='*',
        )

    return parser

def partially_resolve(func, options):
    specs = getfullargspec(func)

    args = []
    kwargs = {}
    for annotation, name, default in collect(specs):
        result = annotation.postaction(options.get(name, None), options)
        args.append(result if not result is None else default)

    args += options.get("*" + func.__name__, [])
    return functools.partial(
        func,
        *args,
        **kwargs
    )

all_underscores = re.compile('_')
def clean_name(name):
    return all_underscores.sub('-', name)


def format_help(help, default):
    if default is None:
        return help
    else:
        return "{help} (default: {default})".format(
            help = help,
            default = default
        )

class CLIArgument:

    def __init__(self, default=None, help=None, action=lambda x:x, type=None):
        self.default = default
        self.action = action
        self.help = help
        self.type = type

    def postaction(self, value, options):
        return self.action(value) if not value is None else None

class SubCommands(CLIArgument):

    def __init__(self, *commands, **kwargs):
        self.commands = { cmd.__name__ : cmd for cmd in commands }
        super(SubCommands, self).__init__(**kwargs)


    def postaction(self, value, options):
        return partially_resolve(
            self.commands[value],
            options
        )

    def parse(self, parser, name, default):
        subparsers = parser.add_subparsers(
            title = "Sub-commands",
            help = format_help(self.help, default),
            dest = name,
        )

        for name, command in self.commands.items():
            subparser = subparsers.add_parser(
                name,
                help = command.__doc__
            )
            funcparser(subparser, command)


class Arg (CLIArgument):
    """An argument.
    """

    def __init__(self, short, **kwargs):
        self.short = short
        super(Arg, self).__init__(**kwargs)

    def parse(self, parser, name, default):
        type_ = self.type or (default is not None and type(default)) or str
        options = {}
        if type_ is bool:
            options["action"] = "store_false" if default else "store_true"
        else:
            options["type"] = type_

        if default is None:
            names = [ clean_name(name) ]
        else:
            names = [ "--" + clean_name(name) ]
            if self.short:
                names += [ self.short ]

        parser.add_argument(
            *names,
            help = format_help(self.help, default),
            **options
        )

class OneOf:

    def __init__(self, **kwargs):
        self.options = kwargs

    def postaction(self, value, options):
        for name, cmd in self.options.items():
            if name in options and not options[name] is None:
                return cmd.postaction(options[name], options)
        return value

    def parse(self, parser, name, default):
        grp = parser.add_mutually_exclusive_group(required = default is None)
        for ename, sub in self.options.items():
            sub.parse(grp, ename, "");
        if not default is None:
            defaults = {}
            defaults[name] = default
            # parser.set_defaults(**defaults)

class ListOf (CLIArgument):

    def __init__(self, short, **kwargs):
        self.short = short
        super(ListOf, self).__init__(**kwargs)

    def parse(self, parser, name, default):
        type_ = self.type or (default and type(default)) or str

        names = [ "--" + clean_name(name) ]
        if self.short:
            names += [ self.short ]

        parser.add_argument(
            *names,
            action = "append",
            help = format_help(self.help, default),
            type=type_
        )

class Enum (CLIArgument):

    def __init__(self, enum, **kwargs):
        self.enum = enum
        super(Enum, self).__init__(**kwargs)

    # def postaction(self, value, options):
    #     return value

    def parse(self, parser, name, default):
        if not default is None:
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
                help =  format_help(self.help, default)
            )
