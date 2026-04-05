if [ -n "$TMUX" ]; then
    [ -f "$TMUX_ENV" ] && source "$TMUX_ENV"
fi

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
