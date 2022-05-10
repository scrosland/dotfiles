#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

if ! git config --global --get core.excludesfile >/dev/null 2>&1 ; then
    run git config --global core.excludesfile $HOME/dotfiles/gitignore.global
fi

if ! git config --global --get commit.verbose >/dev/null 2>&1 ; then
    run git config --global commit.verbose true
fi

# configure pull to fast-forward when possible and merge otherwise ...
if ! git config --global --get pull.ff >/dev/null 2>&1 ; then
    run git config --global pull.ff true
fi

# ... and not to rebase (unless --rebase given on the command line)
if ! git config --global --get pull.rebase >/dev/null 2>&1 ; then
    run git config --global pull.rebase false
fi

# add vscode as a difftool ...
if ! git config --global --get difftool.vscode.cmd >/dev/null 2>&1 ; then
    run git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'
fi

# ... and add as mergetool
if ! git config --global --get mergetool.vscode.cmd >/dev/null 2>&1 ; then
    # At some point vscode might support proper 3-way merges 
    # https://github.com/microsoft/vscode/issues/37350 
    run git config --global mergetool.vscode.cmd 'code --wait $MERGED'
fi

run git lfs install
