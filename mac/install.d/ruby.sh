#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

isInstalled() {
    local name="$1"
    gem info --quiet --silent --installed "${name}" 2>/dev/null
}

if isInstalled iStats; then
    run gem uninstall --silent --executables iStats
fi

quieten=""
if command -v suppress-output-unless-error >/dev/null; then
    quieten="suppress-output-unless-error"
fi
run ${quieten} gem install ruby-lsp
