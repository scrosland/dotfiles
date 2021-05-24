#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

latest=$(curl -sSL https://golang.org/dl |
    grep '/dl/go.*.darwin-amd64.pkg' |
    head -1 |
    cut -d\" -f4 |
    cut -d/ -f3) || true

tmpf="/tmp/${latest}"

trap "rm -f ${tmpf}" EXIT

run curl -sSL "https://golang.org/dl/${latest}" -o "${tmpf}"
run open "${tmpf}"
run go version

run go install golang.org/x/tools/gopls@latest
