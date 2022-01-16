#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

APPLICATIONS="/Applications"
if [[ -e $HOME/.install_to_user_applications ]] ; then
    APPLICATIONS="${HOME}${APPLICATIONS}"
fi
echo "# Installing applications into ${APPLICATIONS}"

# Install brew if needed
brew=$(which brew 2>/dev/null || true)
if [[ -n ${brew} ]] ; then
    echo "Brew is ${brew}"
else
    echo "Brew not found in \$PATH"
    SCRIPT=/tmp/brew.$$
    URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    echo "Getting brew install script."
    run curl -fsSL "${URL}" > ${SCRIPT}
    echo "Check the script before running."
    sleep 5
    less ${SCRIPT}
    echo "Interrupt now or the script will be run"
    sleep 5
    run /bin/bash ${SCRIPT}
    rm -f ${SCRIPT}
fi
unset brew

# Update brew
run brew update

opython=$(brew info python3 | grep libexec || true)

# Install and upgrade packages using bundle ...
BREWFILE="$HOME/dotfiles/mac/Brewfile"
if [[ ! -r ${BREWFILE} ]] ; then
    echo "Cannot find the brewfile, '${BREWFILE}'" >&2
    exit 1
fi
run brew bundle --no-lock --file=${BREWFILE}
# ... and then a manual upgrade just to be sure
run brew upgrade
# Cleanup temporary brew files
run brew cleanup

python=$(brew info python3 | grep libexec || true)
if [[ ${opython} != ${python} ]] ; then
    echo "Python 3.x has been updated to 3.y"
    echo "was: ${opython}"
    echo "is : ${python}"
    echo "It may be necessary to reinstall pip packages"
fi

hash -r

# Copy apps into the applications folder.
# This is not using "brew linkapps" because that creates symlinks into /usr
# which Spotlight will refuse to index.
installer="$(dirname $0)/install_app_or_service.sh"
echo ""
echo "# Copying apps into ${APPLICATIONS}"
cellar=""
case $(uname -p) in
    arm)
        cellar=/opt/homebrew/Cellar
        ;;
    *)
        cellar=/usr/local/Cellar
        ;;
esac
find "${cellar}" -depth 3 -maxdepth 3 -type d -name '*.app' -print |
while read app ; do
    run ${installer} "${app}" "${APPLICATIONS}"
done
