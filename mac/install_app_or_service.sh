#!/bin/bash -e

DRYRUN=

if [[ "$1" = "--dry-run" ]] ; then
    shift
    DRYRUN=1
fi

if [[ $# -ne 2 ]] ; then
    echo "usage: $(basename $0) [--dry-run] source target-directory"
    exit 2
fi

SOURCE="$1"
TARGET="$2"

cmd()
{
    local prefix=""
    if [[ ${DRYRUN} = 1 ]] ; then
        prefix="echo DEBUG:"
    fi
    ${prefix} "$@"
}

install_one()
{
    local src="$1"
    local target="$2"

    if [[ ! -r "${src}" ]] ; then
        return 127
    fi
    local name=$(basename "${src}" | xargs echo)
    local dest="${target}/${name}"
    if [[ -r "${dest}" ]] ; then
        cmd rm -r -f "${dest}"
    fi
    cmd cp -r -f "${src}" "${dest}"
    return 0
}

install_one "${SOURCE}" "${TARGET}"
