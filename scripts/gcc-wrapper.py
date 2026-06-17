#!/usr/bin/env python3
import sys, os
args = sys.argv[1:]
os.execvp(args[0], args)
