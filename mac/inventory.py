#!/usr/bin/env python3

import argparse
from collections import OrderedDict
import json
import plistlib
import os.path
import subprocess
import sys

class Groups(object):
    def __init__(self):
        self.groups = OrderedDict()

    def append(self, title, iterable):
        # iterable is assumed to produce key,value pairs
        self.groups[title] = OrderedDict(sorted(iterable, key=lambda x: x[0]))

    def dump(self):
        if args.json:
            print(json.dumps([self.groups]))
            return
        for title,group in self.groups.items():
            print(f"{title}")
            print("-" * len(title))
            for name,value in group.items():
                print(f"{name}: {value}")
            print("")

groups = Groups()

def not_name(pair):
    name,_ = pair
    return name != "_name"

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
    items = plist[0]["_items"]
    # "items" is a list of dicts. Convert this into a dict of dicts, extracting
    # the "_name" value from the inner dicts to be the key in the outer dict.
    for ii in items:
        yield ii["_name"],dict(filter(not_name, ii.items()))

def interesting_apps(pair):
    """Select interesting applications."""
    _,app = pair
    if app["obtained_from"].lower() == "apple".lower():
        return False
    if app["path"].find("/Applications/") == -1:
        return False
    if "Apple Mac OS Application Signing" in app.get("signed_by", []):
        return False
    return True

def interesting_details(pair):
    """Select which application details to include."""
    name,_ = pair
    return name.lower() == "version" or name.lower() == "path"

def pretty(name):
    return " ".join(name.split("_")).title()

def pretty_keys(pairs):
    for k,v in pairs:
        yield pretty(k),v

def select_applications(apps):
    """Select interesting applications and their details."""
    for name,details in filter(interesting_apps, apps): 
        filtered_details = filter(interesting_details, details.items())
        # The keys of the details are prettified, but not the application name!
        yield name,dict(pretty_keys(filtered_details))

def list_applications():
    apps = select_applications(get_items("SPApplicationsDataType"))
    groups.append("Applications", apps)

def list_hardware():
    items = get_items("SPHardwareDataType")
    title,details = next(items)
    groups.append(pretty(title), pretty_keys(details.items()))

def parse_options():
    parser = argparse.ArgumentParser(
        description="Inventory applications and hardware.")
    parser.add_argument("--json", action="store_true", help="output in JSON")
    global args
    args = parser.parse_args()

if __name__ == "__main__":
    parse_options()
    list_hardware()
    list_applications()
    groups.dump()
