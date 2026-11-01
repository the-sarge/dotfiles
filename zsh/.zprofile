# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/josh/.docker/bin"
# End of Docker Desktop section.

# Added by Toolbox App
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

# Homebrew prefix differs across architectures: /opt/homebrew on Apple Silicon,
# /usr/local on Intel Macs. Probe both rather than hardcoding.
for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
	if [ -x "$brew_path" ]; then
		eval "$("$brew_path" shellenv)"
		break
	fi
done


# Added by Antigravity CLI installer
export PATH="/Users/josh/.local/bin:$PATH"
