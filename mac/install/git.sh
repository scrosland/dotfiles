#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

if ! git config --global --get core.excludesfile >/dev/null 2>&1 ; then
    run git config --global core.excludesfile $HOME/dotfiles/gitignore.global
fi

if ! git config --global --get commit.verbose >/dev/null 2>&1 ; then
    run git config --global commit.verbose true
fi
