#!/bin/bash

run()
{
  echo ""
  echo "# $@"
  "$@"
}

# xcode command line tools
echo "# Checking for Xcode command line tools"
if ! xcode-select --print-path ; then
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
run brew bundle --file=$HOME/dotfiles/mac/Brewfile --verbose
# ... and then a manual upgrade just to be sure
run brew upgrade
# Cleanup temporary brew files
run brew cleanup

hash -r

# Create aliases in /Applications
# This is not using "brew linkapps" because that creates symlinks into /usr
# which Spotlight will refuse to index.
mkalias="$(dirname $0)/mkalias"
echo ""
echo "# Creating application aliases in /Applications"
find /usr/local/Cellar -depth 3 -maxdepth 3 -type d -name '*.app' -print |
  while read app ; do
    run ${mkalias} --force "${app}" /Applications
  done

# python2 packages
run pip2 install mutagen

# python3 packages

# ruby gems
run gem install nokogiri
run gem install redcarpet
run gem install wolfram

echo ""
echo "# Checking for JDK."
if ! /usr/libexec/java_home --failfast ; then
  echo "Cannot find Java."
fi
java -version

if [ ! -r /Applications/SCM.app ] ; then
  echo ""
  echo "# Go to https://github.com/software-jessies-org/jessies/wiki/Downloads and get the latest version of SCM.app."
fi

echo ""
echo "# Go to http://dejavu-fonts.org and install the latest ttf files."

exit 0
