# Keep non-interactive SSH shells able to find Homebrew and local tools.
typeset -U path
path=(/opt/homebrew/bin /usr/local/bin /opt/local/bin $path)
export PATH
