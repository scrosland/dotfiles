#
# vim: set filetype=sh:
#
# Bash functions
#

[ "$(uname)" = "Darwin" ] &&
    [ -f /usr/local/etc/profile.d/bash_completion.sh ] &&
        source /usr/local/etc/profile.d/bash_completion.sh

# echo the abs path of this file (expanding one level of symlink)
this_file()
{
    local source="${BASH_SOURCE[1]}"  # 1 == caller
    local file=$(test -L "$source" && readlink "$source" || echo "$source")
    abs_file "$file" ;
}

# echo the abs path of the running script $0 (no symlink expansion)
this_script()
{
    local source="${BASH_SOURCE[1]}"  # 1 == caller
    abs_file "$source" ;
}

_sc_prompt_command()
{
    printf "\033]0;%s\007" "${TERMINAL_TITLE}"
    if [[ -z $TERMINAL_TITLE ]] ; then
        # borrowed from __vte_prompt_command() as supplied with gnome-terminal
        printf "\033]0;%s@%s:%s\007" \
            "${USER}" \
            "${HOSTNAME%%.*}" \
            "${PWD/#$HOME/~}"
    fi
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
