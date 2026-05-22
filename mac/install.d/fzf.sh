#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

INSTALL="${HOME}/.fzf"
if [[ -d "${INSTALL}" ]]; then
    pushd "${INSTALL}"
    run git fetch
    run git --no-pager log --pretty=oneline HEAD..'@{upstream}'
    run git pull
    popd
else
    run git clone https://github.com/junegunn/fzf.git "${INSTALL}"
fi

run "${INSTALL}/install" --all --no-update-rc
