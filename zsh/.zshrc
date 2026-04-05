[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

# Programming Languages (lazy loading)

## Rust and cargo
activate_rust() {
    if [ "${RUST_ENV_ACTIVATED:-0}" -eq 1 ]; then
        return 0
    fi

    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
        export RUST_ENV_ACTIVATED=1
        return 0
    fi

    echo "activate_rust: could not find $HOME/.cargo/env" >&2
    return 1
}

## JS/TS and Node (nvm)
activate_nvm() {
    if command -v nvm >/dev/null 2>&1; then
        return 0
    fi

    export NVM_DIR="${NVM_DIR:-$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "$HOME/.nvm" || printf %s "$XDG_CONFIG_HOME/nvm")}"

    local nvm_script=""
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        nvm_script="$NVM_DIR/nvm.sh"
    elif [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
        nvm_script="/opt/homebrew/opt/nvm/nvm.sh"
    elif [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
        nvm_script="/usr/local/opt/nvm/nvm.sh"
    fi

    if [ -n "$nvm_script" ]; then
        source "$nvm_script"
        [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
        return 0
    fi

    echo "activate_nvm: could not find nvm.sh (checked $NVM_DIR and Homebrew paths)" >&2
    return 1
}

export ZSH="$HOME/.oh-my-zsh"

source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh

ZVM_INIT_MODE=sourcing
plugins=(zsh-syntax-highlighting zsh-vi-mode fzf)

source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"
