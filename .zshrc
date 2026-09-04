alias vim="nvim"
alias vi="nvim"
alias cdg="cd ~/Documents/GitHub/"
alias cdn="cd ~/Documents/GitHub/notes"
alias cdd="cd ~/.dotfiles/"
alias cdv="cd ~/.config/nvim/"
alias db="rust-gdb"
alias g++="g++ -Wall -Weffc++ -Wextra -Wconversion -Wsign-conversion -Werror -std=c++20"
alias gcc='gcc -Wall -Wextra -Wconversion -Wsign-conversion -Werror -pedantic -std=c17'

export GOROOT="/usr/local/go"
export CMAKEROOT="/usr/local/cmake-4.3.2-linux-x86_64"
export GOPATH="$HOME/.go"
export NVIMPATH="/opt/nvim-linux-x86_64/bin"
export ZIGPATH="$HOME/.zig"
export PSQLPATH="/Library/PostgreSQL/18/bin"
export BINPATH="$HOME/.local/bin"
export OPENCODEPATH=/home/justin/.opencode/bin
export PATH=$PATH:$OPENCODEPATH:$BINPATH:$GOROOT/bin:$GOPATH/bin:$ZIGPATH:$PSQLPATH:$CMAKEROOT/bin:$NVIMPATH:

export LESS='-R'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
# end pyenv

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
zstyle ':vcs_info:git*' formats ' (%F{green}%b%F{green})'

export PS1='%F{green}%(5~|%-1~/⋯/%3~|%4~)%F{green}${vcs_info_msg_0_} >>> %F{white}'

 export NVM_DIR="$HOME/.nvm"
 [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
 [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
 
 [ -f "/Users/justinradatti/.ghcup/env" ] && . "/Users/justinradatti/.ghcup/env" # ghcup-env
 vcs_info setup

