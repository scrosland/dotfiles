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

# Update brew and packages ...
if [[ -e /usr/local/bin/brew ]] ; then
  run brew update
  run brew update
  run brew upgrade
else
# ... or install brew and all packages
  run /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  run brew update

  # Install ffmpeg
  run brew install ffmpeg

  # FLAC
  run brew install flac

  # Install macvim
  if [[ -d /Applications/Xcode.app ]] ; then
    run brew install macvim --with-override-system-vim
  else
    echo "Error: Installation of macvim was skipped as Xcode.app is not installed" >&2
  fi

  # Install newer copy of rsync
  run brew install homebrew/dupes/rsync

  # Install newer copy of python, along with Python Launcher etc.
  run brew install python
  run brew install python3

  # Install newer copy of ruby
  run brew install ruby
fi

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
run pip3 install piexif

# ruby gems
run gem install nokogiri
run gem install redcarpet
run gem install wolfram

echo ""
echo "# Checking for JDK."
java -version

if [ ! -r /Applications/SCM.app ] ; then
  echo ""
  echo "# Go to https://github.com/software-jessies-org/jessies/wiki/Downloads and get the latest version of SCM.app."
fi

echo ""
echo "# Go to http://dejavu-fonts.org and install the latest ttf files."

exit 0
