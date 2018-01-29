#
# vim: set filetype=sh:
#
# Bash functions
#

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

# set terminal title
set_title()
{
    local ansititle="\033]0;${1}\007"
    if [ -z "$(declare -p | grep -s ^ORIG_PROMPT_COMMAND)" ] ; then
        ORIG_PROMPT_COMMAND="${PROMPT_COMMAND}"
    fi
    if [ -z "$1" ] ; then
        PROMPT_COMMAND="${ORIG_PROMPT_COMMAND}"
        if [[ -z ${PROMPT_COMMAND} ]] ; then
            printf "${ansititle}"
        fi
    else
        PROMPT_COMMAND="printf '${ansititle}'"
    fi
}

tmux_session_geometry()
{
    local session="$1"
    details=$(
      command tmux ls -F '#{session_name}:#{session_width}:#{session_height}' |
      grep -s "^${session}:"
      )
    echo "${details}"
    return 0
}

# tmux attach and resize parent terminal to match the target session
tmux_resize_to_match_session()
{
    local session="$1"
    details=$(tmux_session_geometry "${session}")
    if [ -z "${details}" ] ; then 
        echo "error: unknown session '${session}'" >&2
        return 1
    fi
    local _session width height
    IFS=: read _session width height <<< "${details}"
    # add one line to allow for the tmux status bar
    height=$(expr ${height} + 1)
    resize_terminal "${height}" "${width}"
    return 0
}

tma()
{
    local session="$1"
    if ! tmux_resize_to_match_session "${session}" ; then
        return
    fi
    tmux attach -t "${session}"
}
