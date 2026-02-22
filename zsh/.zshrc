export ZSH="$HOME/.oh-my-zsh"

source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh

ZVM_INIT_MODE=sourcing
plugins=(zsh-syntax-highlighting zsh-vi-mode fzf)

source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"
