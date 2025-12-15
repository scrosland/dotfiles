#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

SOURCE="https://github.com/stollcri/nmond"

INSTALLD="${HOME}/bin"
mkdir -p "${INSTALLD}"

VERSION_FILE="${INSTALLD}/nmond.version"
PREVIOUS="none"
if [[ -f "${VERSION_FILE}" ]]; then
    PREVIOUS=$(cat "${VERSION_FILE}")
fi

COMMITS_API="https://api.github.com/repos/stollcri/nmond/commits"
LATEST_VERSION=$(
    curl -sL "${COMMITS_API}" |
        jq -r 'first(.[].sha)'
)

if [[ "${LATEST_VERSION}" != "${PREVIOUS}" ]]; then
    echo "Installing nmond with git rev ${LATEST_VERSION} (previous was ${PREVIOUS})"
else
    echo "nmond version ${LATEST_VERSION} is already installed"
    exit 0
fi

# download, build and install

WORKAREA=$(mktemp -d)

trap 'rm -rf ${WORKAREA}' EXIT

cd ${WORKAREA}
run git clone --depth=1 "${SOURCE}"
echo ""

cd ./nmond/nmond
run make nmond

# Not using `sudo make install` as it seems to work ok without being setuid
run cp ./bin/arm/nmond "${INSTALLD}/."
echo "${LATEST_VERSION}" >"${VERSION_FILE}"
