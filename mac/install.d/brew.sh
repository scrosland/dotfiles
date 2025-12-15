#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

APPLICATIONS="/Applications"
if [[ -e $HOME/.install_to_user_applications ]]; then
    APPLICATIONS="${HOME}${APPLICATIONS}"
    mkdir -p "${HOME}${APPLICATIONS}" || true
fi
echo "# Installing applications into ${APPLICATIONS}"

# Install brew if needed
brew=$(which brew 2>/dev/null || true)
if [[ -n ${brew} ]]; then
    echo "Brew is ${brew}"
else
    echo "Brew not found in \$PATH"
    SCRIPT=/tmp/brew.$$
    URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    echo "Getting brew install script."
    run curl -fsSL "${URL}" >${SCRIPT}
    echo "Check the script before running."
    sleep 5
    less ${SCRIPT}
    echo "Interrupt now or the script will be run"
    sleep 5
    run /bin/bash ${SCRIPT}
    rm -f ${SCRIPT}
    PATH="/opt/homebrew/bin:${PATH}"
fi
unset brew

# Update brew
run brew update

# From 4.0 the taps of homebrew/core and homebre/cask are not needed
for tap in homebrew/core homebrew/cask; do
    if [[ $(brew tap-info ${tap} | grep -c "Not installed") = 0 ]]; then
        run brew untap ${tap}
    fi
done

opython=$(brew info python3 | grep libexec || true)

# Install and upgrade packages using bundle ...
BREWFILE="$HOME/dotfiles/mac/Brewfile"
if [[ ! -r ${BREWFILE} ]]; then
    echo "Cannot find the brewfile, '${BREWFILE}'" >&2
    exit 1
fi
run brew bundle --file=${BREWFILE}
# ... and then a manual upgrade just to be sure
run brew upgrade
# Cleanup temporary brew files
run brew cleanup

echo ""
echo "# Checking python3 version"
python=$(brew info python3 | grep libexec || true)
if [[ ${opython} != ${python} ]]; then
    echo "Python 3.x has been updated to 3.y"
    echo "was: ${opython}"
    echo "is : ${python}"
    echo "It may be necessary to reinstall pip packages"
else
    echo "Python 3.x remains the same version"
    echo "ref: ${python}"
fi

hash -r

# Copy apps into the applications folder.
# This is not using "brew linkapps" because that creates symlinks into /usr
# which Spotlight will refuse to index.

echo ""
echo "# Copying apps into ${APPLICATIONS}"
run $(realpath "$(dirname $0)/../brew-copy-apps")
echo ""

# Stop the isync service which otherwise runs every 5 minutes
brew services stop isync >/dev/null

if [[ ! -L ${HOME}/bin/clang-format ]]; then
    mkdir -p ${HOME}/bin
    ln -s $(command -v clang-format) ${HOME}/bin/clang-format
fi
