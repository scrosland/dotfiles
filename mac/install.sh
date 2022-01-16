#!/bin/bash -e

cd $(dirname $0)

install/xcode.sh
install/brew.sh
# fix the PATH in case this was an install from clean
source ../environment
install/bash.sh
install/git.sh
install/golang.sh
install/java.sh
install/ruby.sh
install/scm.sh
