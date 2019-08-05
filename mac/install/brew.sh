#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

APPLICATIONS="/Applications"
if [[ -e $HOME/.install_to_user_applications ]] ; then
    APPLICATIONS="${HOME}${APPLICATIONS}"
fi
echo "# Installing applications into ${APPLICATIONS}"

# Install brew if needed
if [[ ! -e /usr/local/bin/brew ]] ; then
    SCRIPT=/tmp/brew.$$
    URL="https://raw.githubusercontent.com/Homebrew/install/master/install"
    echo "Getting brew install script."
    run curl -fsSL "${URL}" > ${SCRIPT}
    echo "Check the script before running."
    sleep 5
    less ${SCRIPT}
    echo "Interrupt now or the script will be run"
    sleep 5
    run /usr/bin/ruby ${SCRIPT}
    rm -f ${SCRIPT}
fi

# Update brew
run brew update

# Install and upgrade packages using bundle ...
BREWFILE="$HOME/dotfiles/mac/Brewfile"
if [[ ! -r ${BREWFILE} ]] ; then
    echo "Cannot find the brewfile, '${BREWFILE}'" >&2
    exit 1
fi
run brew bundle --file=${BREWFILE}
# ... and then a manual upgrade just to be sure
run brew upgrade
# Cleanup temporary brew files
run brew cleanup

hash -r

# Copy apps into the applications folder.
# This is not using "brew linkapps" because that creates symlinks into /usr
# which Spotlight will refuse to index.
installer="$(dirname $0)/install_app_or_service.sh"
echo ""
echo "# Copying apps into ${APPLICATIONS}"
find /usr/local/Cellar -depth 3 -maxdepth 3 -type d -name '*.app' -print |
while read app ; do
    run ${installer} "${app}" "${APPLICATIONS}"
done