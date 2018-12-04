#!/bin/bash -e

cd $HOME

if [[ ! -r /etc/debian_version ]] ; then
    echo "Error: cannot find /etc/debian_version: is this a Debian install?" >&1
    exit 1
fi

sudo apt-get update 
sudo apt-get upgrade

sudo apt-get install aptitude

sudo aptitude install bind9-host
sudo aptitude install curl
sudo aptitude install git
sudo aptitude install ipcalc
sudo aptitude install jq 
sudo aptitude install lsb-release
sudo aptitude install man-db
sudo aptitude install python python3
sudo aptitude install ssh
sudo aptitude install ttf-dejavu
sudo aptitude install vim-gnome

lsb_release -a

if [[ ! -d $HOME/.ssh ]] ; then
    echo "Setting up ssh"
    mkdir $HOME/.ssh
    chmod 2700 $HOME/.ssh
    ls -ld $HOME/.ssh
    ssh-keygen -t rsa
    ssh-keygen -t ecdsa -b 521
    ls -l $HOME/.ssh
fi

if [[ ! -r $HOME/.git/config ]] ; then
    echo "Setting up git"
    read -p"Enter email for git: " INPUT
    git config --global user.email "${INPUT}"
    read -p"Enter username for git: " INPUT
    git config --global user.name "${INPUT}"
    git config --global color.pager false
    git config --global core.excludesfile $HOME/dotfiles/gitignore.global
    git config --global credential.helper store
    git config --global web.browser sensible-browser
    git config --global --list
fi

if [[ ! -r $HOME/.inputrc ]] ; then
    echo "Setting up dotfiles"

    echo ". \$HOME/dotfiles/startup" >$HOME/.bashrc
    echo ". \$HOME/dotfiles/startup" >$HOME/.profile
    echo "\$include $HOME/dotfiles/inputrc" >$HOME/.inputrc
    echo "source \$HOME/dotfiles/vim/vimrc" > $HOME/.vimrc
    echo "source \$HOME/dotfiles/vim/gvimrc" > $HOME/.gvimrc
fi

if [[ ! -d $HOME/.vim/bundle ]] ; then
    vim -c 'call plugins#bootstrap()'
    vim -c 'PlugInstall'
fi
