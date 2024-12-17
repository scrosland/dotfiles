#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

SOURCE="https://github.com/stollcri/nmond"

WORKAREA=$(mktemp -d)

trap 'rm -rf ${WORKAREA}' EXIT

cd ${WORKAREA}
run git clone --depth=1 "${SOURCE}"
cd ./nmond/nmond
run make nmond

INSTALLD="${HOME}/bin"
mkdir -p "${INSTALLD}"
# Not using `sudo make install` as it seems to work ok without being setuid
run cp ./bin/arm/nmond "${INSTALLD}/."
