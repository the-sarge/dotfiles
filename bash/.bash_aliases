if [[ -n 'which eza' ]]; then
	alias ls="eza"
fi

# alias ls="ls -FG"
# alias l="ls -1FG"
# alias la="ls -1aFG"
# alias ll="ls -alFGh"
# alias lt="ls -ltFGh"
# alias ldot="ls -ldFGh .*"
alias lv="ll /Volumes"

alias bb="bbedit --wait --resume"
alias vi="nvim"
alias vim="nvim"

# alias zshconfig="bbedit ~/.zshrc"

if [[ -n 'which tmuxinator' ]]; then
	alias mux="tmuxinator"
fi