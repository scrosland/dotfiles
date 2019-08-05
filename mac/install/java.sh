#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

downloadURL()
{
    local infoURL="$1"
    curl -sSL "${infoURL}" | jq '.binaries|.[]|.installer_link' | tail -1
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
echo "# Latest releases of interest:"
downloadURL $(infoURL openjdk8)
downloadURL $(infoURL openjdk11)
