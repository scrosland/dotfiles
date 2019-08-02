#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

# Install bash
LOCALBASH=/usr/local/bin/bash
if [[ -x ${LOCALBASH} ]] ; then
    if ! grep -q -s ${LOCALBASH} /etc/shells ; then
        echo "# Adding ${LOCALBASH} to the available shells"
        echo "# This will require sudo"
        echo ${LOCALBASH} | sudo tee -a /etc/shells
    fi
    CURRENTSHELL=$(dscl . -read ${HOME} UserShell | awk '{print $NF}' -)
    if [[ ${CURRENTSHELL} != ${LOCALBASH} ]] ; then
        echo "# Changing shell to ${LOCALBASH} from ${CURRENTSHELL}"
        run chsh -s ${LOCALBASH}
        echo "# Close and reopen the terminal to use the new shell"
    fi
fi
