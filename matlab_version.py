#!/usr/bin/env python3
"""
Tests several versions of Matlab using Lmod module (for Linux)
relies on tests/version_runner.m

"module" requires shell=True

both by Michael Hirsch June 2020
"""
import subprocess
import sys
import platform

if platform.system() != "Linux":
    raise SystemExit("This script for Linux only")

# the tests take several minutes, so we didn't test every possible version
wanted_matlab = ['2017a', '2020a']

failed = 0

for w in wanted_matlab:
    k = f"matlab/{w}"
    ret = subprocess.run(f"module avail {k}", stderr=subprocess.PIPE, universal_newlines=True, shell=True)
    if k not in ret.stderr:
        print(f"SKIP: {k} not available", file=sys.stderr)
        continue

    mod_cmd = f"module load {k}"
    if int(w[:4]) < 2019:
        bat = "matlab -r -nodesktop -nosplash"
    else:
        bat = "matlab -batch"

    ret = subprocess.run(mod_cmd + " && " + bat + " version_runner", universal_newlines=True, shell=True, cwd='tests')
    if ret.returncode != 0:
        failed += 1


if failed == 0:
    print("OK:", wanted_matlab)
else:
    print(failed, " Matlab versions failed", file=sys.stderr)
