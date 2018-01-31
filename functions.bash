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

# ----- tmux helpers -----

# gets a custom user option
tmux_get_custom_session_option()
{
    local session="$1"
    local option="$2"
    # use of the 'start \; show-options' idiom allows this
    # to work even when the tmux server is not running
    command tmux start \; \
        show-options -g -v "@session_${session}_${option}" 2>/dev/null
}

# gets the geometry of a running session
tmux_session_geometry()
{
    local session="$1"
    local format='#{session_name}:#{session_width}:#{session_height}'
    details=$(
      command tmux list-sessions -F "${format}" 2>/dev/null |
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
        return 1
    fi
    local _session width height
    IFS=: read _session width height <<< "${details}"
    # add one line to allow for the tmux status bar
    height=$(expr ${height} + 1)
    resize_terminal "${width}" "${height}"
    return 0
}

tmux_reattach()
{
    local session="$1"
    if ! tmux_resize_to_match_session "${session}" ; then
        return 1
    fi
    command tmux attach -t "${session}"
}

tmux_create_session()
{
    local session="$1"
    if command tmux has-session -t "${session}" 2>/dev/null ; then
        echo "error: session '${session}' is already running" >&2
        return 1
    fi
    local width height
    IFS="x" read width height <<< $(
        tmux_get_custom_session_option "${session}" "geometry" 2>/dev/null
        )
    if [[ -z ${width} ]] || [[ -z ${height} ]] ; then
        echo "error: cannot find the default geometry for '${session}'"
        return 1
    fi
    command tmux new-session -d -s "${session}" -x "${width}" -y "${height}"
    if (( $? != 0 )) ; then
        echo "error: failed to create new session '${session}'" >&2
    fi
    local pane=$(command tmux list-panes -t "${session}" -F '#{pane_id}')
    local cmds
    IFS='§' cmds=( $(
        tmux_get_custom_session_option "${session}" "command"
        ) )
    for cmd in "${cmds[@]}" ; do
        eval command ${cmd} -t "${pane}"
    done
    return 0
}

tmux_start_or_attach()
{
    local session="$1"
    if tmux_reattach "${session}" ; then
        return 0
    fi
    if ! tmux_create_session "${session}" ; then
        return 1
    fi
    tmux_reattach "${session}"
}

tmux()
{
    local command="$1"
    if [[ ${command} = "go" ]] ; then
        local session="$2"
        if [[ -z ${session} ]] ; then
            echo "usage: tmux go <target-session>" >&2
            return 2
        fi
        tmux_start_or_attach "$2"
        return $?
    fi
    command tmux "$@"
}
