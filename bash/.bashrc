export CLICOLOR=1
export PATH=$PATH


if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='vim'
	export PAGER='less'
else
	export EDITOR='/usr/local/bin/bbedit --wait --resume'
	export PAGER='most'
fi


PS1="\n\[\033[0;36m\][\u@\h] \w \n$ \[\033[0m\]"


# Aliases
source ~/.dotfiles/bash/.bash_aliases

# Functions
source ~/.dotfiles/bash/.bash_functions
