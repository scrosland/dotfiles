#!/usr/bin/env python3

from collections import OrderedDict
import json
import plistlib
import os.path
import subprocess
import sys

options = {
        "json": False,
        }

class Groups(object):
    def __init__(self):
        self.groups = []

    def append(self, _dict):
        self.groups.append(OrderedDict(sorted(_dict.items())))

    def dump(self):
        if options["json"]:
            print(json.dumps(self.groups))
            return
        for grp in self.groups:
            for name, value in grp.items():
                print(f"{name!r}: {value!r}")
            print("")

groups = Groups()

def get_items(data_type):
    command = [ "system_profiler", "-xml", data_type ]
    try:
        child = subprocess.run(command,
                               check=True,
                               stdout=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        print(f"Error: failed to get {data_type} items from system_profiler")
        raise e
    plist = plistlib.loads(child.stdout, fmt=plistlib.FMT_XML)
    return plist[0]["_items"]

def interesting(app):
    if app["obtained_from"].lower() == "apple".lower():
        return False
    if app["path"].find("/Applications/") == -1:
        return False
    return True

def list_applications():
    items = get_items("SPApplicationsDataType")
    apps = { app["_name"]: app["path"] for app in filter(interesting, items) }
    groups.append(apps)

def list_hardware():
    items = get_items("SPHardwareDataType")
    groups.append(items[0])

def parse_options():
    if len(sys.argv) == 1:
        return 0
    if len(sys.argv) != 2:
        usage()
    if sys.argv[1] == "--json":
        options["json"] = True
    else:
        usage()

def usage():
    print(f"usage: {os.path.basename(sys.argv[0])} [--json]")
    sys.exit(127)

if __name__ == "__main__":
    parse_options()
    list_hardware()
    list_applications()
    groups.dump()
