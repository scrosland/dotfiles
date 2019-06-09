#!/bin/bash

run()
{
  echo ""
  echo "# $@"
  "$@"
}

APPLICATIONS="/Applications"
if [[ -e $HOME/.install_to_user_applications ]] ; then
    APPLICATIONS="${HOME}${APPLICATIONS}"
fi
echo "# Installing applications into ${APPLICATIONS}"

# xcode command line tools
echo "# Checking for Xcode command line tools"
if ! xcode-select --print-path ; then
  run xcode-select --install
fi
if ! clang --version >/dev/null 2>&1 ; then
  run xcode-select --install
fi

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

# Install bash
LOCALBASH=/usr/local/bin/bash
if [[ -x ${LOCALBASH} ]] ; then
    if ! grep -q -s ${LOCALBASH} /etc/shells ; then
        echo "# Adding ${LOCALBASH} to the available shells"
        echo "# This will require sudo"
        echo ${LOCALBASH} | sudo tee -a /etc/shells
    fi
    CURRENTSHELL=$(dscl . -read ${HOME} UserShell | awk '{print $NF}' -)
    if [[ ${CURRENTSHELL} != ${LOCALBASH} ]] ; then
        echo "# Changing shell to ${LOCALBASH} from ${CURRENTSHELL}"
        run chsh -s ${LOCALBASH}
        echo "# Close and reopen the terminal to use the new shell"
    fi
fi

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

echo ""
echo "# Checking for JDK."
if ! /usr/libexec/java_home --failfast ; then
  echo "Cannot find Java."
fi
echo "# Default java version."
java -version
echo "# All installed JDKs."
ls -1 /Library/Java/JavaVirtualMachines

if [[ ! -r /Applications/SCM.app ]] &&
   [[ ! -r "${HOME}/Applications/SCM.app" ]] ; then
  echo ""
  echo "# Go to https://github.com/software-jessies-org/jessies/wiki/Downloads and get the latest version of SCM.app."
fi

exit 0
