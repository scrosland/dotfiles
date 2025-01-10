# syntax: bash
# vim: set filetype=sh:
#
# Bash functions
#
# dotfiles/functions ensures that this is only run for interactive shells
#

if [ -z "${BASH_VERSION}" ]; then
    return
fi

# Tell bash to trim all but this number of directories from '\w'
PROMPT_DIRTRIM=2

_sc_cwd()
{
    printf "${PWD/#${HOME}/\~}"
}

_sc_prompt_path_core()
{
    local cwd="$(_sc_cwd)"
    if (("${#cwd}" <= 35)) || [[ -n "${PROMPT_FULL_PATH}" ]]; then
        echo "${cwd}"
        return 0
    fi
    local prefix="~/"
    if [[ "${cwd}" != "${prefix}*" ]]; then
        prefix="${cwd:0:5}"
    fi
    local headtail="${prefix}...${cwd: -20}"
    echo "${headtail}"
    return 0
}

_sc_prompt_path_trim()
{
    if [[ -n "${PROMPT_FULL_PATH}" ]]; then
        _sc_cwd
        return 0
    fi
    echo '\w'
}

_sc_prompt_path_shorten()
{
    local cwd="$(_sc_cwd)"
    if (("${#cwd}" <= 25)) || [[ -n "${PROMPT_FULL_PATH}" ]]; then
        echo "${cwd}"
        return 0
    fi
    local path_parent=${cwd%\/*}
    #local path_parent_short=$(echo $path_parent | sed -r 's|/([^/][^/]\|[^/])[^/]*|/\1|g') # 2 char directory names
    local path_parent_short=$(echo $path_parent | sed -r 's|/(.)[^/]*|/\1|g') # 1 char directory names
    local directory=${cwd##*\/}
    echo "$path_parent_short/$directory"
}

_SC_PROMPT_PATH=_sc_prompt_path_trim

# This moves the prompt back to the start of a line even if the proceding
# command failed to output a trailing newline. To show that the command output
# was missing the newline it outputs a descriptive end mark.
#
# See https://www.vidarholen.net/contents/blog/?p=878, and
# https://news.ycombinator.com/item?id=23520240 and
# PROMPTSP in the Zsh source code at
# https://github.com/zsh-users/zsh/blob/master/Src/utils.c.
#
# Decent looking end marks
#   §  U+00A7
#   ↵  U+21B5
#   ⟸  U+27F8
#   ⤆  U+2906
#   ←  U+2190
#   ¶  U+00B6
_sc_prompt_reset()
{
    # bold helps the end mark stand out
    printf "\e[1m↵\e[m%$((COLUMNS - 1))s\r" ""
}

_sc_prompt_string()
{
    # based on __vte_prompt_command() as supplied with gnome-terminal
    printf "%s%s@%s:%s" \
        "${debian_chroot:+($debian_chroot)}" \
        "${USER}" \
        "${HOSTNAME%%.*}" \
        "$(${_SC_PROMPT_PATH})"
}

_sc_prompt_command()
{
    _sc_prompt_reset

    local level=""
    if ((${IS_LOGIN_SHELL} == 0 && ${SHLVL} > 1)); then
        declare -i count=$(((${SHLVL} - 1) * 2))
        printf -v level "%.*s" ${count} '\$\$\$\$\$\$\$\$\$'
    fi
    local options="$(__git_ps1)" # e.g. git branch
    local prompt="$(_sc_prompt_string)"
    printf -v PS1 "${prompt}${options}${level}\$ "

    printf "\033]0;%s\007" "${TERMINAL_TITLE:-${prompt/\\w/$(_sc_cwd)}}"
    return 0
}

_sc_csi_decset_state()
{
    local ps="$1"
    local onoff
    case "$2" in
    on | ON)
        onoff="h"
        ;;
    off | OFF)
        onoff="l"
        ;;
    *)
        echo "error: \"$2\" unknown option, should be \"on\" or \"off\"" >&2
        return 1
        ;;
    esac
    printf '\e[?%s%s' "${ps}" "${onoff}"
}

application-cursor()
{
    # Turn on/off application cursor
    _sc_csi_decset_state 1 "$1"
}

mouse-reporting()
{
    # Turn on/off mouse reporting
    _sc_csi_decset_state 1000 "$1"
}

# set terminal title
set_title()
{
    TERMINAL_TITLE="$1"
    return 0
}

if [ -z "$(which sfind)" ]; then
    sfind()
    {
        rg --files "$@" | sed -e 's/^/"/' -e 's/$/"/'
    }
fi

PROMPT_COMMAND="_sc_prompt_command"

source_when_readable \
    /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash \
    /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh \
    "${GHOSTTY_RESOURCES_DIR}/../bash-completion/completions/ghostty.bash" \
    /usr/local/etc/profile.d/bash_completion.sh \
    /etc/profile.d/bash_completion.sh

if [[ -r $HOME/.fzf.bash ]]; then
    _fzf_compgen_path()
    {
        fzf-list-command "$1"
    }
    FZF_DEFAULT_COMMAND="fzf-list-command"
    export FZF_DEFAULT_COMMAND
    FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_CTRL_T_COMMAND
    FZF_DEFAULT_OPTS="--color=light --cycle"
    export FZF_DEFAULT_OPTS
    source $HOME/.fzf.bash
fi

# ----- END -----
