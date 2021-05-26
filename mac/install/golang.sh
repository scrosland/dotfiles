#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

GO111MODULE=on ; export GO111MODULE
run go install golang.org/x/tools/gopls@latest
