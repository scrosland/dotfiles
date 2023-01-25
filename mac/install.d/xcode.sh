#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

# xcode-select starts a separate app "Install Command Line Developer Tools.app"
# to do the actual installation, so this function needs to wait for that to
# complete
install_xcode() {
    run xcode-select --install
    sleep 2 # wait for the app to start
    while [[ -n $(ps -fe | egrep '[I]nstall Command Line Developer Tools') ]]; do
        sleep 5
    done
}

# xcode command line tools
echo "# Checking for Xcode command line tools"
if ! xcode-select --print-path; then
    install_xcode
fi
if ! clang --version >/dev/null 2>&1; then
    install_xcode
fi
