#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

# The best GitHub theme I can find:
#   https://github.com/cdalvaro/github-vscode-theme-iterm

THEME_NAME="GitHub Light Default"
THEME_URL='https://raw.githubusercontent.com/cdalvaro/github-theme-iterm/HEAD/GitHub%20Light%20Default.itermcolors'

SAVE_DIRECTORY="${HOME}/Library/Application Support/iTerm2/scrosland"
THEME_FILENAME="${THEME_NAME}.itermcolors"
THEME="${SAVE_DIRECTORY}/${THEME_FILENAME}"

installed=$(plutil -p ${HOME}/Library/Preferences/com.googlecode.iterm2.plist | grep "${THEME_NAME}" || true)
if [[ -n "${installed}" ]]; then
    echo "Theme \"${THEME_NAME}\" is already installed in iTerm preferences"
else
    mkdir -p "${SAVE_DIRECTORY}"
    curl -sSL -o "${THEME}" "${THEME_URL}"
    echo "# Theme saved as: ${THEME}"
    echo "# About to install ${THEME_NAME}"
    sleep 1
    open "${THEME}"
fi
