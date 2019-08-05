#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

checkForUpdate()
{
    local baseversion="$1"

    local infoJSON=$(infoData $(infoURL "openjdk${baseversion}"))
    local updated=$(echo "${infoJSON}" | updatedAt "${baseversion}")

    local installed=$(installedAt "${baseversion}")

    # The API update time can be a short while after the birth time of the
    # Info.plist, so don't suggest an update unless there's a significant delta
    local delta=$(( ${updated} - ${installed} ))
    local secondsInDay=86400
    if (( ${delta} > ${secondsInDay} )) ; then
        echo "New OpenJDK ${baseversion} available:"
        echo "${infoJSON}" | downloadURL
    fi
}

downloadURL()
{
    # infoData will be read from stdin
    jq '.binaries|.[]|.installer_link' | tail -1 | xargs echo
}

installedAt()
{
    local baseversion="$1"
    stat -f%B "/Library/Java/JavaVirtualMachines/adoptopenjdk-${baseversion}.jdk/Contents/Info.plist"
}

updatedAt()
{
    # infoData will be read from stdin
    jq '.timestamp' | tail -1 | xargs echo |
        ruby -e 'require "time" ; puts Time.parse($stdin.readline()).to_i()'
}

infoData()
{
    local infoURL="$1"
    curl -sSL "${infoURL}"
}

infoURL()
{
    local version="$1"
    echo "https://api.adoptopenjdk.net/v2/info/releases/${version}?openjdk_impl=hotspot&os=mac&release=latest&type=jdk"
}

if ls -1 /Library/Java/JavaVirtualMachines | grep -qs ^jdk ; then
    echo "# *** Removing old Oracle JDKs ***"
    sudo rm -rf /Library/Java/JavaVirtualMachines/jdk*
fi
echo "# Checking for JDK."
if ! /usr/libexec/java_home --failfast ; then
    echo "Cannot find Java."
fi

echo ""
echo "# Default java version."
java -version
echo ""
echo "# All installed JDKs."
#ls -1 /Library/Java/JavaVirtualMachines
/usr/libexec/java_home --verbose 2>&1 | sed -e '/^$/,$d'

echo ""
echo "# New JDKs can be downloaded from https://adoptopenjdk.net/"
checkForUpdate 8
checkForUpdate 11
