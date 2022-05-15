#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

# The best GitHub theme I can find:
#   https://github.com/cdalvaro/github-vscode-theme-iterm
THEME="${HOME}/Downloads/GitHub Light Default.itermcolors"
curl -o "${THEME}" 'https://raw.githubusercontent.com/cdalvaro/github-theme-iterm/HEAD/GitHub%20Light%20Default.itermcolors'
echo "# About to install GitHub Light Default theme for iTerm2."
echo "# Do not install it twice!"
sleep 1
open "${THEME}"
