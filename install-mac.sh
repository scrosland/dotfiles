#!/bin/bash

# Update brew and packages ...
if [[ -e /usr/local/bin/brew ]] ; then
  brew update
  brew update
  brew upgrade
else
# ... or install brew and all packages
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew update

  # Install ffmpeg
  brew install ffmpeg

  # FLAC
  brew install flac

  # Install macvim
  if [[ -d /Applications/Xcode.app ]] ; then
    brew install macvim --with-override-system-vim
  else
    echo "Error: Installation of macvim was skipped as Xcode.app is not installed" >&2
  fi

  # Install newer copy of rsync
  brew install homebrew/dupes/rsync

  # Install newer copy of python, along with Python Launcher etc.
  brew install python
fi

# Create links into /Applications
brew linkapps
# Convert the symlinks into aliases so that they show in Spotlight, see
# https://github.com/Homebrew/legacy-homebrew/issues/16639 for the source
find /Applications -maxdepth 1 -type l | while read f ; do osascript -e "tell app \"Finder\" to make new alias file at POSIX file \"/Applications\" to POSIX file \"$(readlink "$f")\"" ; rm "$f" ; done

# Cleanup temporary files
brew cleanup

echo "Go to http://dejavu-fonts.org and install the latest ttf files."

exit 0
