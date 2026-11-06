# MacOS Homebrew
[ -f "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Local profile
[ -f "$HOME/.local_env" ] && source "$HOME/.local_env"

# macOS runs path_helper from /etc/zprofile, so reorder user bins here.
typeset -U path PATH

if [ -d "$HOME/bin" ] ; then
    path=("$HOME/bin" $path)
fi
if [ -d "$HOME/.local/bin" ] ; then
    path=("$HOME/.local/bin" $path)
fi

if [ -n "$TMUX" ]; then
    [ -f "$TMUX_ENV" ] && source "$TMUX_ENV"
fi

if [[ -n "$HC_TERMINAL_ID" && "$TERM_PROGRAM" != herdr ]]; then
    unset HERDR_WORKSPACE_ENV
    herdr_space_id=$(hc --json get "$HC_TERMINAL_ID" 2>/dev/null |
        python3 -c 'import json, sys; print(json.load(sys.stdin).get("labels", {}).get("herdr.space", ""))' 2>/dev/null) || herdr_space_id=
    if [[ -n "$herdr_space_id" && "$herdr_space_id" != */* && "$herdr_space_id" != . && "$herdr_space_id" != .. ]]; then
        herdr_space_env="${XDG_CONFIG_HOME:-$HOME/.config}/herdr_spaces_env/$herdr_space_id"
        if [[ -f "$herdr_space_env" ]]; then
            export HERDR_WORKSPACE_ENV="$herdr_space_env"
            source "$HERDR_WORKSPACE_ENV"
        fi
    fi
    unset herdr_space_id herdr_space_env
elif [ -n "$HERDR_ENV" ]; then
    if [[ ! -f "$HERDR_WORKSPACE_ENV" && -n "$HERDR_WORKSPACE_ID" ]]; then
        herdr_session="${HERDR_SESSION:-default}"
        if [[ "$herdr_session" != */* && "$herdr_session" != . && "$herdr_session" != .. &&
              "$HERDR_WORKSPACE_ID" != */* && "$HERDR_WORKSPACE_ID" != . && "$HERDR_WORKSPACE_ID" != .. ]]; then
            herdr_space_env="${XDG_CONFIG_HOME:-$HOME/.config}/herdr_spaces_env/herdr/$herdr_session/$HERDR_WORKSPACE_ID"
            [[ -f "$herdr_space_env" ]] && export HERDR_WORKSPACE_ENV="$herdr_space_env"
        fi
        unset herdr_session herdr_space_env
    fi
    [ -f "$HERDR_WORKSPACE_ENV" ] && source "$HERDR_WORKSPACE_ENV"
fi
