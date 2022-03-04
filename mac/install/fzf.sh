#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

INSTALL="${HOME}/.fzf"
if [[ -d "${INSTALL}" ]] ; then
    git -C "${INSTALL}" pull
else
    git clone https://github.com/junegunn/fzf.git "${INSTALL}"
fi

"${INSTALL}/install" --all --no-update-rc