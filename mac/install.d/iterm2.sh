#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

# The best GitHub theme I can find:
#   https://github.com/cdalvaro/github-vscode-theme-iterm
THEME="${HOME}/Library/Application Support/iTerm2/scrosland/GitHub Light Default.itermcolors"
if [[ ! -r "${THEME}" ]] ; then
    curl -sSL -o "${THEME}" 'https://raw.githubusercontent.com/cdalvaro/github-theme-iterm/HEAD/GitHub%20Light%20Default.itermcolors'
    echo "# Theme saved as: ${THEME}"
    echo "# About to install $(basename "${THEME}")"
    sleep 1
    open "${THEME}"
fi
