#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import getopt
import json


def scan(logfile):
    result = {}
    keys = {}
    try:
        with open(logfile, "r+") as f:
            lines = [ln.split(":")[1] for ln in f]
            for idx, ln in enumerate(lines):
                attributes = {}
                for param in ln.split(","):
                    key, value = [
                        k.replace(" ", "") for k in param.strip().split("=")
                    ]
                    keys[key] = value
                    attributes[key] = value

                context = attributes['Context']
                if context not in result.keys():
                    result[context] = {}

                for key in attributes.keys():
                    if key not in result[context].keys():
                        result[context][key] = []
                    if key not in [
                            'Context', 'Hostname', 'ProcessName', 'SessionId'
                    ]:
                        result[context][key].append(attributes[key])
                    else:
                        result[context][key] = attributes[key]
            f.seek(0)
            f.truncate()
    except IOError:
        print "Error, file nout found"
        sys.exit(-1)
    return result


def main(argv):
    inputfile, outputfile = "", ""
    help_string = "Usage:\n./%s -i <input_file> -o <output_file>" % (argv[0])
    try:
        opts, args = getopt.getopt(argv[1:], "hi:o:", ["input", "output"])
    except getopt.GetoptError:
        print help_string
        sys.exit(2)

    for opt, arg in opts:
        if opt == "-h":
            print help_string
            sys.exit()
        elif opt in ("-i", "--input"):
            inputfile = arg
        elif opt in ("-o", "--output"):
            outputfile = arg

    result = scan(inputfile)
    try:
        with open(outputfile, "w") as f:
            f.write(json.dumps(result))
    except IOError:
        print "Error, cant read or write to file '%s'" % outputfile
        sys.exit(2)


if __name__ == "__main__":
    main(sys.argv)
    print 0
