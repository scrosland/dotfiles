#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

if ! git config --global --get core.excludesfile >/dev/null 2>&1; then
    run git config --global core.excludesfile $HOME/dotfiles/gitignore.global
fi

if ! git config --global --get commit.verbose >/dev/null 2>&1; then
    run git config --global commit.verbose true
fi

# ensure git uses "main" as the default branch in new repos
if ! git config --global --get init.defaultBranch >/dev/null 2>&1; then
    run git config --global init.defaultBranch main
fi

# configure pull to fast-forward when possible and merge otherwise ...
if ! git config --global --get pull.ff >/dev/null 2>&1; then
    run git config --global pull.ff true
fi

# ... and not to rebase (unless --rebase given on the command line)
if ! git config --global --get pull.rebase >/dev/null 2>&1; then
    run git config --global pull.rebase false
fi

# always remove deleted remote branches on fetch
if ! git config --global --get fetch.prune >/dev/null 2>&1; then
    run git config --global fetch.prune true
fi

# add vscode as a difftool ...
if ! git config --global --get difftool.vscode.cmd >/dev/null 2>&1; then
    run git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'
fi

# ... remove previous mergetool configuration ...
if ! git config --global --get mergetool.vscode.cmd 2>/dev/null | grep -q -s -- '--merge'; then
    run git config --global --unset mergetool.vscode.cmd || true
fi

# ... and add as mergetool (now supporting 3-way merges)
if ! git config --global --get mergetool.vscode.cmd >/dev/null 2>&1; then
    run git config --global mergetool.vscode.cmd 'code --wait --merge $REMOTE $LOCAL $BASE $MERGED'
fi

# install git lfs for the current user
if ! git config --global --get filter.lfs.process >/dev/null 2>&1; then
    run git -C $HOME lfs install
fi
