#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

INSTALL="${HOME}/.fzf"
if [[ -d "${INSTALL}" ]] ; then
    run git -C "${INSTALL}" pull
else
    run git clone https://github.com/junegunn/fzf.git "${INSTALL}"
fi

run "${INSTALL}/install" --all --no-update-rc