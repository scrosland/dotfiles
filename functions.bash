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

# Update the current bash environment from the tmux session environment.
# This ensures that e.g. DISPLAY is set correctly even when switching 
# between clients.
#   c.f. tmux set-option update-environment
tmux_update_environment()
{
    if [[ -n ${TMUX} ]] ; then
        eval $(command tmux show-environment -s)
    fi
}

__sc_prompt_command()
{
    printf "\033]0;%s\007" "${TERMINAL_TITLE}"
    if [[ -z $TERMINAL_TITLE ]] ; then
        if [[ -n ${ORIG_PROMPT_COMMAND} ]] ; then
            eval "${ORIG_PROMPT_COMMAND}"
        fi
    fi
    tmux_update_environment
    return 0
}

# set terminal title
set_title()
{
    TERMINAL_TITLE="$1"
    if ! declare -p ORIG_PROMPT_COMMAND >/dev/null 2>&1 ; then
        ORIG_PROMPT_COMMAND="${PROMPT_COMMAND}"
    fi
    PROMPT_COMMAND="__sc_prompt_command"
    __sc_prompt_command
    return 0
}

# From the bash man page:
#   "PS1 is set and $- includes i if bash is interactive, allowing a
#    shell script or a startup file to test this state."
if [[ -n $PS1 ]] ; then
    set_title
fi

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

tmux_current_session()
{
    if [[ -z $TMUX ]] ; then
        echo ""
        return 1
    fi
    command tmux display-message -p '#{session_name}'
    return 0
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

tmux_configure_window()
{
    local session=$(tmux_current_session)
    local pane=''

    if [[ $# -gt 0 ]] ; then
        session="$1"      # optional session name -- for the layout commands
    fi
    if [[ $# -gt 1 ]] ; then
        pane="$2"         # optional pane id
    fi

    local cmds
    IFS='§' cmds=( $(
        tmux_get_custom_session_option "${session}" "command"
        ) )
    for cmd in "${cmds[@]}" ; do
        eval command ${cmd} ${pane:+"-t"} ${pane}
    done
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
    tmux_configure_window "${session}" "${pane}"
    return 0
}

tmux_start_or_attach()
{
    local session="$1"
    set_title "${session}"
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
    case "${command}" in
        go)
            shift
            if [[ $# -lt 1 ]] ; then
                echo "usage: tmux go <target-session>" >&2
                return 2
            fi
            tmux_start_or_attach "$@"
            return $?
            ;;
        conf)
            shift
            tmux_configure_window "$@"
            return $?
            ;;
        update-environment|updateenv|upenv)
            tmux_update_environment
            return $?
            ;;
    esac
    command tmux "$@"
}
