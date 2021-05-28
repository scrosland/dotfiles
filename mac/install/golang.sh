#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

GO111MODULE=on ; export GO111MODULE

TOOLS=()
TOOLS+=( golang.org/x/tools/gopls@latest )
TOOLS+=( github.com/fatih/motion@latest )
TOOLS+=( github.com/jstemmer/gotags@master )
TOOLS+=( honnef.co/go/tools/cmd/keyify@master )
TOOLS+=( honnef.co/go/tools/cmd/staticcheck@latest )

declare -p TOOLS

for tool in "${TOOLS[@]}" ; do
    run go install "${tool}"
done
