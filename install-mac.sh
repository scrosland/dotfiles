#!/bin/bash

run()
{
  echo ""
  echo "# $@"
  "$@"
}

# mkalias source_file directory_containing_alias
# e.g. mkalias /usr/local/Cellar/macvim/8.0-120/MacVim.app /Applications
# This will replace any existing file of the same name in the target directory.
mkalias()
{
  local srcfile="$1"
  local aliasdir="$2"
  local alias="${aliasdir}/$(basename "${srcfile}" '.app')"
  if [[ -f "$alias" ]] ; then
    rm "$alias"
  fi
  osascript -e "tell app \"Finder\" to make new alias file at POSIX file \"$aliasdir\" to POSIX file \"$srcfile\""
  if [[ ! -f "$alias" ]] ; then
    local actual=$(ls -1t "${alias} alias"* | head -1)
    echo "# Finder misnamed the alias '${actual}', renaming ..."
    mv "${actual}" "${alias}"
    ls -1 "${alias}"*
  fi
}

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
fi

# Create aliases in /Applications
# This is not using "brew linkapps" because that creates symlinks into /usr
# which Spotlight will refuse to index.
echo ""
echo "# Creating application aliases in /Applications"
find /usr/local/Cellar -depth 3 -type d -name '*.app' -print |
  while read app ; do
    run mkalias "${app}" /Applications
  done

# Cleanup temporary files
run brew cleanup

echo ""
echo "Go to http://dejavu-fonts.org and install the latest ttf files."

exit 0
