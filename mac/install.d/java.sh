#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

checkForUpdate() {
    local baseversion="$1"

    local infoJSON=$(infoData $(infoURL "${baseversion}"))
    if [[ -z ${infoJSON} ]]; then
        echo "No OpenJDK available for Java ${baseversion} on $(architecture)"
        return
    fi

    local updated=$(echo "${infoJSON}" | updatedAt "${baseversion}")
    local installed=$(installedAt "${baseversion}")

    # The API update time can be a short while after the birth time of the
    # Info.plist, so don't suggest an update unless there's a significant delta
    local delta=$((${updated} - ${installed}))
    local secondsInDay=86400
    if ((${delta} > ${secondsInDay})); then
        version=$(echo "${infoJSON}" | releaseName)
        echo "New OpenJDK ${baseversion} available (${version}):"
        echo "${infoJSON}" | downloadURL
    fi
}

downloadURL() {
    # infoData will be read from stdin
    jq '.binary|.installer|.link' | tail -1 | xargs echo
}

installedAt() {
    local baseversion="$1"
    stat -f%B "/Library/Java/JavaVirtualMachines/*-${baseversion}.jdk/Contents/Info.plist" 2>/dev/null || echo 0
}

releaseName() {
    jq '.release_name' | tail -1 | xargs echo
}

updatedAt() {
    # infoData will be read from stdin
    jq '.binary|.updated_at' | tail -1 | xargs echo |
        ruby -e 'require "time" ; puts Time.parse($stdin.readline()).to_i()'
}

infoData() {
    local infoURL="$1"
    curl -sSL "${infoURL}" | jq '.[]' | cat
}

architecture() {
    case "$(uname -m)" in
    x86_64 | amd64)
        echo "x64"
        ;;
    arm*)
        echo "aarch64"
        ;;
    *)
        echo "unknown architecture: $(uname -a)" >&2
        exit 1
        ;;
    esac
}

infoURL() {
    local version="$1"
    echo "https://api.adoptium.net/v3/assets/latest/${version}/hotspot?architecture=$(architecture)&image_type=jdk&os=mac&vendor=eclipse"
}

if ls -1 /Library/Java/JavaVirtualMachines | grep -qs ^jdk; then
    echo "# *** Removing old Oracle JDKs ***"
    sudo rm -rf /Library/Java/JavaVirtualMachines/jdk*
fi
echo "# Checking for JDK."
if /usr/libexec/java_home --failfast; then
    echo ""
    echo "# Default java version."
    java -version || true
    echo ""
    echo "# All installed JDKs."
    #ls -1 /Library/Java/JavaVirtualMachines
    (/usr/libexec/java_home --verbose 2>&1 || true) | sed -e '/^$/,$d'
else
    echo "Cannot find Java."
fi

echo ""
echo "# New JDKs can be downloaded from https://adoptopenjdk.net/"
checkForUpdate 8
checkForUpdate 11
checkForUpdate 17
