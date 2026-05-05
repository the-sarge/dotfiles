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

# Auto-load GitHub SSH key into ssh-agent when available and absent.
if [[ -o interactive && -n $SSH_AUTH_SOCK && -r $HOME/.ssh/GitHub && -r $HOME/.ssh/GitHub.pub ]]; then
	github_key_fingerprint=$(ssh-keygen -lf "$HOME/.ssh/GitHub.pub" 2>/dev/null | awk '{print $2}')
	if [[ -n $github_key_fingerprint ]] && ! ssh-add -l 2>/dev/null | grep -Fq "$github_key_fingerprint"; then
		ssh-add -q "$HOME/.ssh/GitHub" </dev/null 2>/dev/null
	fi
	unset github_key_fingerprint
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
# Homebrew
export PATH="$PATH:/opt/homebrew/bin"
# Go
export PATH="$PATH:/usr/local/go/bin"
if command -v go >/dev/null 2>&1; then
	export PATH="$PATH:$(go env GOPATH)/bin"
fi
# LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# opencode
export PATH="$PATH:$HOME/.opencode/bin"
# Antigravity
export PATH="/Users/josh/.antigravity/antigravity/bin:$PATH"
# gcloud-cli
export PATH=/opt/homebrew/share/google-cloud-sdk/bin:"$PATH"


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


test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

