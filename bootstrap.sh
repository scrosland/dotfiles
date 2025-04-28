#!/bin/sh -eu
#
# Deliberately use the lowest common denominator shell, i.e. POSIX shell.

#DEBUG=true
DEBUG=${DEBUG:-false}

maybe()
{
    if ${DEBUG}; then
        printf "# "
        printf "'%s' " "$@"
        printf "\n"
        return 0
    fi
    "$@"
}

wait_for_user()
{
    echo "$@"
    printf "Press return."
    read _dummy
}

do_chmod()
{
    _dst="$1"
    shift
    if [ -n "$*" ]; then
        _mode="$1"
        shift
        chmod "${_mode}" "${_dst}"
    fi
}

install_file()
{
    _src="$1"
    shift
    _dst="$1"
    shift
    if [ -e "${_dst}" ]; then
        mv "${_dst}" "${_dst}.bootstrap"
    fi
    cat "${_src}" >"${_dst}"
    do_chmod "${_dst}" "$@"
}

#
# main
#

if [ -z $(command -v git) ]; then
    echo "Cannot find the git command." >&2
    echo "How did we get here without using cloning the dotfiles repo?!" >&2
    exit 101
fi

if [ -e "${HOME}/.vimrc" -a -e "${HOME}/.gvimrc" ]; then
    echo ".vimrc and .gvimrc exist - has bootstrap already been run?" >&2
    exit 102
fi

printf "Git email address: "
read _email
printf "Git user name (first last): "
read _name
maybe git config --global user.email "${_email}"
maybe git config --global user.name "${_name}"
unset _email _name
maybe git config --global core.excludesfile ${HOME}/dotfiles/gitignore.global
maybe git config --global commit.verbose true
maybe git config --global pull.ff true
maybe git config --global pull.rebase false

cd ${HOME}/dotfiles/skeleton
for skel in *; do
    maybe install_file "${skel}" "${HOME}/.${skel}"
done
maybe sed -i.bootstrap -e "s!%HOME%!${HOME}!g" ${HOME}/.inputrc

mkdir -p "${HOME}/.config"
cd "${HOME}/dotfiles/config"
for cf in *; do
    maybe ln -sf "${HOME}/dotfiles/config/${cf}" "${HOME}/.config/${cf}"
done
cd "${HOME}"

# dotfiles/environment requires ~/bin to fix up degenerate macOS paths
mkdir "${HOME}"/bin

wait_for_user "About to bootstrap vim configuration."
maybe vim -c "call plugins#bootstrap()"
maybe vim -c "PlugInstall"

echo ""
echo "Optional local configuration:"
echo "Create \$HOME/.vim/after/plugin/local.vim if required."
echo "Create \$HOME/.{environment,functions,shrc}.local if required."
echo ""

if [ $(uname -s) = "Darwin" ]; then
    while :; do
        printf "Should apps be installed locally in \$HOME/Applications? [yn] "
        read _choice
        case "${_choice}" in
        y | Y)
            maybe touch ${HOME}/.install_to_user_applications
            break
            ;;
        n | N)
            break
            ;;
        esac
    done

    wait_for_user "About to install macOS tools."
    maybe ${HOME}/dotfiles/mac/install.sh

    echo ""
    echo "Optional:"
    echo "Install Marked2 from https://marked2app.com."
fi
