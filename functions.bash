#
# vim: set filetype=sh:
#
# Bash functions
#

[ "$(uname)" = "Darwin" ] &&
    [ -f /usr/local/etc/profile.d/bash_completion.sh ] &&
        source /usr/local/etc/profile.d/bash_completion.sh

_sc_prompt_path()
{
    local tilde="~"
    local cwd="${PWD/#$HOME/${tilde}}"
    if (( "${#cwd}" <= 35 )) ; then
        echo "${cwd}"
        return 0
    fi
    local prefix="~/"
    if [[ "${cwd}" != "${prefix}*" ]] ; then
        prefix="${cwd:0:5}"
    fi
    local headtail="${prefix}...${cwd: -20}"
    echo "${headtail}"
    return 0
}

_sc_prompt_string()
{
    # based on __vte_prompt_command() as supplied with gnome-terminal
    printf "%s%s@%s:%s" \
        "${debian_chroot:+($debian_chroot)}" \
        "${USER}" \
        "${HOSTNAME%%.*}" \
        "$(_sc_prompt_path)"
}

_sc_prompt_command()
{
    local level=""
    if (( ${IS_LOGIN_SHELL} == 0 && ${SHLVL} > 1 )) ; then
        level="<${SHLVL}> "
    fi
    local vim="${VIM_TERMINAL:+ [vim]}"
    local prompt="$(_sc_prompt_string)"
    printf -v PS1 "${prompt}${vim}\$ ${level}"

    printf "\033]0;%s\007" "${TERMINAL_TITLE:-${prompt}}"
    return 0
}

# set terminal title
set_title()
{
    TERMINAL_TITLE="$1"
    return 0
}

# From the bash man page:
#   "PS1 is set and $- includes i if bash is interactive, allowing a
#    shell script or a startup file to test this state."
if [[ -n $PS1 ]] ; then
    PROMPT_COMMAND="_sc_prompt_command"
fi

# ----- iterm helpers -----

if [[ "${TERM_PROGRAM}" = "iTerm.app" ]] ; then
    . "${BASH_SOURCE[0]/%bash/iterm}"
fi


# ----- END -----
