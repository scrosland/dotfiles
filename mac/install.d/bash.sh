#!/bin/bash -e

source "$(dirname $0)/functions.shlib"

# Install bash
LOCALBASH=""
case $(uname -p) in
arm)
    LOCALBASH=/opt/homebrew/bin/bash
    ;;
*)
    LOCALBASH=/usr/local/bin/bash
    ;;
esac
if [[ -x ${LOCALBASH} ]]; then
    if ! grep -q -s ${LOCALBASH} /etc/shells; then
        if ! $(id -Gn | grep -q -s -w admin); then
            echo "# Cannot add ${LOCALBASH} to the available shells - not in group admin(80)" >&2
            exit 1
        fi
        echo "# Adding ${LOCALBASH} to the available shells"
        echo "# This will require sudo"
        echo ${LOCALBASH} | sudo tee -a /etc/shells
    fi
    CURRENTSHELL=$(dscl . -read ${HOME} UserShell | awk '{print $NF}' -)
    if [[ ${CURRENTSHELL} != ${LOCALBASH} ]]; then
        echo "# Changing shell to ${LOCALBASH} from ${CURRENTSHELL}"
        run chsh -s ${LOCALBASH}
        echo "# Close and reopen the terminal to use the new shell"
    fi
fi
