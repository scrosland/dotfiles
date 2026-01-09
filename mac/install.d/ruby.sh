#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

run gem uninstall --silent --executables iStats

run gem install ruby-lsp
