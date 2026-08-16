# Keep non-interactive SSH shells able to find Homebrew and local tools.
typeset -U path
_zshenv_tool_dirs=()
for _zshenv_tool_dir in \
	"$HOME/.local/bin" \
	/opt/homebrew/bin /opt/homebrew/sbin \
	/usr/local/bin /usr/local/sbin \
	/opt/local/bin /opt/local/sbin \
	/usr/local/go/bin "$HOME/go/bin"; do
	[[ -d "$_zshenv_tool_dir" ]] && _zshenv_tool_dirs+=("$_zshenv_tool_dir")
done
path=($_zshenv_tool_dirs $path)
unset _zshenv_tool_dir _zshenv_tool_dirs
export PATH

# VM homes live on an external infra volume, deliberately off the boot disk.
# The volume name differs per machine (lab-2TB here, infra-2TB on mbp128 and
# eventually imacpro), so probe rather than hardcode -- same approach .zprofile
# uses for the Homebrew prefix.
#
# Two deliberate choices:
#
#   Test for "$vol/infra", not just "$vol". imacpro already has an infra-2TB
#   volume with no infra/ directory yet (migration: the-sarge/infra#203), so
#   volume presence alone would point LIMA_HOME at a path that does not exist.
#   Testing the directory makes that migration its own switch: imacpro starts
#   getting these exports the day the directory appears, with no edit here.
#
#   Use an explicit candidate list, not a /Volumes/*/infra glob. /Volumes/worktrees
#   also contains an infra directory on m4mini and mbp128, and a glob would match
#   it non-deterministically.
_infra_root=""
for _infra_candidate in /Volumes/lab-2TB /Volumes/infra-2TB; do
	if [[ -d "$_infra_candidate/infra" ]]; then
		_infra_root="$_infra_candidate"
		break
	fi
done

if [[ -n "$_infra_root" ]]; then
	export LIMA_HOME="$_infra_root/infra/lima"
	export GARM_LOCAL_PROVIDER_TART_HOME="$_infra_root/infra/tart-garm"
else
	# Fail closed. These are external USB drives that sometimes drop; leaving
	# the variables unset would make lima silently fall back to ~/.lima and
	# rebuild VMs on the boot disk, which is exactly what moving them off it
	# was meant to prevent. Point at a sentinel that cannot exist instead:
	# /Volumes is root-owned 0755, so nothing can be created there and any
	# lima/tart command fails immediately with a path that names the problem.
	export LIMA_HOME=/Volumes/infra-volume-not-mounted/lima
	export GARM_LOCAL_PROVIDER_TART_HOME=/Volumes/infra-volume-not-mounted/tart-garm
	[[ -o interactive ]] && print -u2 "warning: no infra volume mounted (checked lab-2TB, infra-2TB); LIMA_HOME/GARM_LOCAL_PROVIDER_TART_HOME point at an absent path so nothing lands on the boot disk"
fi
unset _infra_root _infra_candidate
