# Keep non-interactive SSH shells able to find Homebrew and local tools.
typeset -U path
_zshenv_tool_dirs=()
for _zshenv_tool_dir in \
	/opt/homebrew/bin /opt/homebrew/sbin \
	/usr/local/bin /usr/local/sbin \
	/opt/local/bin /opt/local/sbin; do
	[[ -d "$_zshenv_tool_dir" ]] && _zshenv_tool_dirs+=("$_zshenv_tool_dir")
done
path=($_zshenv_tool_dirs $path)
unset _zshenv_tool_dir _zshenv_tool_dirs
export PATH
