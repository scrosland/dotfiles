#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

TMPFILE=$(mktemp /tmp/github.XXXXXX)
trap 'rm -f ${TMPFILE}' EXIT

# Check if GiHub CLI is authenticated
if gh auth status --active >${TMPFILE} 2>&1; then
    account=$(awk '/github.com account/ {print $(NF-1)}' ${TMPFILE})
    if [[ ${account} = scroslandhv ]]; then
        echo "# GitHub CLI is authenticated as ${account}."
        if ! gh extension list | grep -q gh-copilot; then
            echo "# Installing GitHub Copilot extension."
            run gh extension install github/gh-copilot
        else
            echo "# Upgrading GitHub Copilot extension."
            run gh extension upgrade gh-copilot
        fi
    fi
else
    echo "GitHub CLI is not authenticated. Skipping further setup."
fi
