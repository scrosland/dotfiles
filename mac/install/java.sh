#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

echo ""
if ls -1 /Library/Java/JavaVirtualMachines | grep -qs ^jdk ; then
    echo "# *** Removing old Oracle JDKs ***"
    sudo rm -rf /Library/Java/JavaVirtualMachines/jdk*
fi
echo "# Checking for JDK."
if ! /usr/libexec/java_home --failfast ; then
    echo "Cannot find Java."
fi
echo "# Default java version."
java -version
echo "# All installed JDKs."
#ls -1 /Library/Java/JavaVirtualMachines
/usr/libexec/java_home --verbose
echo "# New JDKs can be downloaded from https://adoptopenjdk.net/"
