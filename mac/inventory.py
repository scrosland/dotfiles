#!/usr/bin/env python3

import json
import plistlib
import subprocess
import sys

def interesting(app):
    if app["obtained_from"].lower() == "apple".lower():
        return False
    if app["path"].find("/Applications/") == -1:
        return False
    return True

if __name__ == "__main__":
    command = [ "system_profiler", "-xml", "SPApplicationsDataType" ]
    try:
        child = subprocess.run(command,
                               check=True,
                               stdout=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        print("failed to get list of applications from system_profiler")
        raise e
    plist = plistlib.loads(child.stdout, fmt=plistlib.FMT_XML)
    items = plist[0]["_items"]
    apps = { app["_name"]: app["path"] for app in filter(interesting, items) }
    if len(sys.argv) > 1 and sys.argv[1] == "--json":
        print(json.dumps([apps], sort_keys=True))
    else:
        for name, path in apps.items():
            print(f"{name!r}: {path!r}")
    sys.exit(0)
