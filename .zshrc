alias vim="nvim"
alias vi="nvim"
alias cdg="cd ~/Documents/GitHub/"
alias cdn="cd ~/Documents/GitHub/notes"
alias cdd="cd ~/.dotfiles/"

export GOPATH="$HOME/.go"
export ZIGPATH="$HOME/.zig"
export PSQLPATH="/Library/PostgreSQL/18/bin"
export PATH=$PATH:$GOPATH/bin:$ZIGPATH:$PSQLPATH

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

bindkey -e

# Prompt
setopt prompt_subst

autoload -Uz vcs_info 
precmd () { vcs_info }
zstyle ':vcs_info:git*' formats ' (%F{153}%b%F{153})'

export PS1='%F{153}%(5~|%-1~/⋯/%3~|%4~)%F{153}${vcs_info_msg_0_} >>> %F{255}'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
