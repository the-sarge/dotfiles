# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

export CLICOLOR=1

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='hx'
	export PAGER='less'
else
	export EDITOR='/usr/local/bin/bbedit --wait --resume'
	export PAGER='less'
fi

# Auto-load SSH keys into ssh-agent when no identities are present
ssh-add -l >/dev/null 2>&1 || ssh-add ~/.ssh/GitHub

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
# Homebrew
export PATH="$PATH:/opt/homebrew/bin"
# Go
export PATH="$PATH:/usr/local/go/bin:$(go env GOPATH)/bin"
# LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# opencode
export PATH="$PATH:$HOME/.opencode/bin:$PATH"
# Antigravity
export PATH="/Users/josh/.antigravity/antigravity/bin:$PATH"

# # carapace
# autoload -U compinit && compinit
# export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
# zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
# source <(carapace _carapace)

# Starship
eval "$(starship init zsh)"

# zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-syntax-highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# zoxide
eval "$(zoxide init zsh)"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Aliases
source ~/.dotfiles/zsh/.zsh_aliases

# Functions
source ~/.dotfiles/zsh/.zsh_functions


