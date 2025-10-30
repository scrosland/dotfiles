#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

SOURCE="https://github.com/stollcri/nmond"

INSTALLD="${HOME}/bin"
mkdir -p "${INSTALLD}"

VERSION_FILE="${INSTALLD}/nmond.version"

WORKAREA=$(mktemp -d)

trap 'rm -rf ${WORKAREA}' EXIT

cd ${WORKAREA}
run git clone --depth=1 "${SOURCE}"
echo ""

cd ./nmond/nmond
CURRENT=$(git rev-list --max-count=1 HEAD)
PREVIOUS="none"
if [[ -f "${VERSION_FILE}" ]]; then
    PREVIOUS=$(cat "${VERSION_FILE}")
fi
if [[ "${CURRENT}" != "${PREVIOUS}" ]]; then
    echo "Installing nmond with git rev ${CURRENT} (previous was ${PREVIOUS})"
else
    echo "nmond version ${CURRENT} is already installed"
    exit 0
fi

run make nmond

# Not using `sudo make install` as it seems to work ok without being setuid
run cp ./bin/arm/nmond "${INSTALLD}/."
echo "${CURRENT}" > "${VERSION_FILE}"
