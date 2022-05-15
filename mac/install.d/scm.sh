#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

URL="https://github.com/software-jessies-org/jessies/wiki/Downloads"

if [[ ! -r /Applications/SCM.app ]] &&
   [[ ! -r "${HOME}/Applications/SCM.app" ]] ; then
    echo ""
    echo "# Go to ${URL} and get the latest version of SCM.app."
fi
