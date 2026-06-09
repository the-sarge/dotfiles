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

export EDITOR='hx'
export PAGER='less'

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

# PATH (Homebrew is set up earlier by .zprofile via `brew shellenv`,
# which exports HOMEBREW_PREFIX/PATH/etc. We append/prepend per-tool here.)
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

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
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Antigravity IDE
export PATH="/Users/josh/.antigravity-ide/antigravity-ide/bin:$PATH"

# gcloud-cli (installed via `brew install --cask google-cloud-sdk`)
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -d "$HOMEBREW_PREFIX/share/google-cloud-sdk/bin" ]; then
	export PATH="$HOMEBREW_PREFIX/share/google-cloud-sdk/bin:$PATH"
fi

# mamacli - granola
export GRANOLA_ENV_FILE="${GRANOLA_ENV_FILE:-$HOME/.config/mamacli/granola.env.op}"
granola() {
  command -v op >/dev/null 2>&1 || { echo "op CLI not found" >&2; return 127; }
  [[ -f "$GRANOLA_ENV_FILE" ]] || { echo "missing $GRANOLA_ENV_FILE" >&2; return 1; }
  op run --env-file="$GRANOLA_ENV_FILE" -- command granola "$@"
}


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


# Per-machine conda init lives outside dotfiles; run `conda init zsh` to (re)generate.

# Aliases
source ~/.dotfiles/zsh/.zsh_aliases

# Functions
source ~/.dotfiles/zsh/.zsh_functions


test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


source ~/.config/broot/launcher/bash/br



# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<
