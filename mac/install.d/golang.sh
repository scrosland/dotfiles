#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

GO111MODULE=on
export GO111MODULE

TOOLS=()

# language server
TOOLS+=(golang.org/x/tools/gopls@latest)

# for vim-go
TOOLS+=(github.com/fatih/motion@latest)
TOOLS+=(github.com/go-delve/delve/cmd/dlv@latest)
TOOLS+=(github.com/jstemmer/gotags@master)

# for vscode-go and vim-go
TOOLS+=(github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest)
TOOLS+=(github.com/mgechev/revive@latest)
TOOLS+=(golang.org/x/tools/cmd/goimports@latest)
TOOLS+=(honnef.co/go/tools/cmd/staticcheck@latest)

declare -p TOOLS

for tool in "${TOOLS[@]}"; do
    run go install "${tool}"
done
