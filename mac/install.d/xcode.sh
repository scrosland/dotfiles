#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

# xcode command line tools
echo "# Checking for Xcode command line tools"
if ! xcode-select --print-path ; then
    run xcode-select --install
fi
if ! clang --version >/dev/null 2>&1 ; then
    run xcode-select --install
fi
