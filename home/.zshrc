# omz config
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-nvm zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh


# opencode config
export PATH="$HOME/.opencode/bin:$PATH"

# go config
if command -v go >/dev/null 2>&1; then
	export PATH="$PATH:$(go env GOPATH)/bin"
fi

# tmux config
export PATH="$HOME/.config/tmux-sessionizer:$PATH"

# aliases
alias lp='lsof -i -P -n | grep LISTEN'
alias vi='nvim'
alias lg='lazygit'

# key mappings
bindkey -s ^f "tmux-sessionizer\n"
