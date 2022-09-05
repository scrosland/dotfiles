#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

# The best GitHub theme I can find:
#   https://github.com/cdalvaro/github-vscode-theme-iterm
SAVE_DIRECTORY="${HOME}/Library/Application Support/iTerm2/scrosland"
THEME_NAME="GitHub Light Default.itermcolors"
THEME="${SAVE_DIRECTORY/${THEME_NAME}"
if [[ ! -r "${THEME}" ]] ; then
    mkdir -p "${SAVE_DIRECTORY}"
    curl -sSL -o "${THEME}" 'https://raw.githubusercontent.com/cdalvaro/github-theme-iterm/HEAD/GitHub%20Light%20Default.itermcolors'
    echo "# Theme saved as: ${THEME}"
    echo "# About to install ${THEME_NAME}"
    sleep 1
    open "${THEME}"
fi
