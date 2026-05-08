#!/usr/bin/env bash
# Migrate selected ~/.config/<name>/ dirs into stow-managed ~/.dotfiles/<pkg>/.config/<name>/.
# DRY_RUN=1 by default. Set DRY_RUN=0 to actually move files.
set -euo pipefail

DOTFILES="${DOTFILES:-${HOME}/.dotfiles}"
CONFIG="${CONFIG:-${HOME}/.config}"
DRY_RUN="${DRY_RUN:-1}"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/tmp/dotfiles-migration-${TS}"

# format: "package_name:source_basename"
# (source_basename is what lives under ~/.config/; package_name is the stow pkg dir)
MIGRATIONS=(
  "broot:broot"
  "btop:btop"
  "ccstatusline:ccstatusline"
  "ghostty:ghostty"
  "nvim:nvim"
  "zellij:zellij"
)
GIT_ADDON_FILES=( "allowed_signers" "ignore" )

declare -a MIGRATED=() SKIPPED=() FAILED=()

log() { printf '%s\n' "$*" >&2; }
run() {
  if [ "$DRY_RUN" = "1" ]; then
    log "DRY:  $*"
  else
    log "RUN:  $*"
    "$@"
  fi
}

stow_pkg() {
  # Real run only. Captures stderr to $2. Dry-run skips this -- stow can't honestly
  # validate a plan against a tree where the moves haven't happened.
  local pkg="$1" stow_err="$2"
  if [ "$DRY_RUN" = "1" ]; then
    log "DRY:  (skipping stow check; runs for real on DRY_RUN=0)"
    return 0
  fi
  (cd "$DOTFILES" && stow "$pkg") 2>"$stow_err"
}

preflight() {
  [ -d "$DOTFILES/.git" ]    || { log "FATAL: $DOTFILES is not a git repo"; exit 1; }
  command -v stow >/dev/null || { log "FATAL: stow not found on PATH"; exit 1; }

  local d_dev c_dev
  d_dev="$(stat -f %d "$DOTFILES")"
  c_dev="$(stat -f %d "$CONFIG")"
  [ "$d_dev" = "$c_dev" ] || {
    log "FATAL: $DOTFILES and $CONFIG on different volumes; mv would not be atomic"
    exit 1
  }

  # target packages must have no unstaged changes (lets us roll back via git if needed)
  local entry pkg dirty
  for entry in "${MIGRATIONS[@]}" "git:_addon"; do
    pkg="${entry%%:*}"
    dirty="$(cd "$DOTFILES" && git status --porcelain -- "$pkg" 2>/dev/null || true)"
    if [ -n "$dirty" ]; then
      log "FATAL: target package '$pkg' has unstaged changes:"
      log "$dirty"
      log "Resolve with:  (cd $DOTFILES && git stash push -- $pkg)  -- or commit first."
      exit 1
    fi
  done

  mkdir -p "$BACKUP_DIR"
  log "Pre-flight OK. DRY_RUN=$DRY_RUN. Backups -> $BACKUP_DIR"
}

migrate_pkg() {
  local pkg="$1" name="$2"
  local src="${CONFIG}/${name}"
  local pkg_target="${DOTFILES}/${pkg}/.config/${name}"
  log
  log "=== ${pkg} (${src} -> ${pkg_target}) ==="

  if [ ! -e "$src" ];               then SKIPPED+=("$pkg: src missing");         return; fi
  if [ -L "$src" ];                 then SKIPPED+=("$pkg: src already symlink"); return; fi
  if [ -z "$(/bin/ls -A "$src")" ]; then SKIPPED+=("$pkg: src empty");           return; fi

  if [ -e "$pkg_target" ] && [ -n "$(/bin/ls -A "$pkg_target" 2>/dev/null)" ]; then
    log "CONFLICT: $pkg_target already non-empty -- review manually:"
    diff -rq "$src" "$pkg_target" 2>&1 | head -20 >&2 || true
    SKIPPED+=("$pkg: pkg target non-empty (manual review)")
    return
  fi

  run cp -a "$src" "${BACKUP_DIR}/${name}"
  if [ -d "$pkg_target" ]; then run rmdir "$pkg_target"; fi
  run mkdir -p "$(dirname "$pkg_target")"
  run mv "$src" "$pkg_target"

  local stow_err="${BACKUP_DIR}/${pkg}.stow.stderr"
  if ! stow_pkg "$pkg" "$stow_err"; then
    log "FAIL: stow $pkg refused -- see $stow_err"
    [ -s "$stow_err" ] && cat "$stow_err" >&2 || true
    log "Rolling back: restoring $src"
    run mv "$pkg_target" "$src"
    FAILED+=("$pkg: stow failed (see $stow_err)")
    return
  fi

  if [ "$DRY_RUN" = "1" ]; then
    MIGRATED+=("$pkg (dry-run)")
    return
  fi

  local resolved
  resolved="$(readlink -f "$src" 2>/dev/null || true)"
  if [ "$resolved" = "$pkg_target" ]; then
    MIGRATED+=("$pkg")
  else
    log "FAIL: post-stow verify, $src resolves to '$resolved' (expected $pkg_target)"
    FAILED+=("$pkg: verify failed")
  fi
}

migrate_git_addon() {
  log
  log "=== git addon (~/.config/git/{${GIT_ADDON_FILES[*]}}) ==="
  local pkg_target="${DOTFILES}/git/.config/git"
  local f src moved_any=0
  run mkdir -p "$pkg_target"
  for f in "${GIT_ADDON_FILES[@]}"; do
    src="${CONFIG}/git/${f}"
    if [ ! -f "$src" ];                 then SKIPPED+=("git/$f: missing");           continue; fi
    if [ -L "$src" ];                   then SKIPPED+=("git/$f: already symlink");   continue; fi
    if [ -e "${pkg_target}/${f}" ];     then SKIPPED+=("git/$f: pkg already has it"); continue; fi
    run cp -a "$src" "${BACKUP_DIR}/git_${f}"
    run mv "$src" "${pkg_target}/${f}"
    moved_any=1
  done

  if [ "$moved_any" = "0" ] && [ "$DRY_RUN" != "1" ]; then
    log "git addon: nothing to do"
    return
  fi

  local stow_err="${BACKUP_DIR}/git.stow.stderr"
  if ! stow_pkg "git" "$stow_err"; then
    log "FAIL: stow git refused -- see $stow_err"
    [ -s "$stow_err" ] && cat "$stow_err" >&2 || true
    FAILED+=("git addon: stow failed (manual rollback needed)")
    return
  fi

  if [ "$DRY_RUN" = "1" ]; then
    MIGRATED+=("git addon (dry-run)")
    return
  fi

  local ok=1 r expected
  for f in "${GIT_ADDON_FILES[@]}"; do
    [ -e "${CONFIG}/git/${f}" ] || continue
    expected="${pkg_target}/${f}"
    r="$(readlink -f "${CONFIG}/git/${f}" 2>/dev/null || true)"
    if [ "$r" != "$expected" ]; then
      log "FAIL: ${CONFIG}/git/${f} -> '$r' (expected $expected)"
      ok=0
    fi
  done
  if [ "$ok" = "1" ]; then MIGRATED+=("git addon"); else FAILED+=("git addon: verify failed"); fi
}

main() {
  preflight
  local entry pkg name
  for entry in "${MIGRATIONS[@]}"; do
    pkg="${entry%%:*}"
    name="${entry##*:}"
    migrate_pkg "$pkg" "$name"
  done
  migrate_git_addon

  log
  log "==== SUMMARY ===="
  log "migrated: ${#MIGRATED[@]}"
  if [ "${#MIGRATED[@]}" -gt 0 ]; then for x in "${MIGRATED[@]}"; do log "  + $x"; done; fi
  log "skipped:  ${#SKIPPED[@]}"
  if [ "${#SKIPPED[@]}"  -gt 0 ]; then for x in "${SKIPPED[@]}";  do log "  - $x"; done; fi
  log "failed:   ${#FAILED[@]}"
  if [ "${#FAILED[@]}"   -gt 0 ]; then for x in "${FAILED[@]}";   do log "  ! $x"; done; fi
  log "Backups retained at $BACKUP_DIR; remove when satisfied."
  [ "${#FAILED[@]}" -eq 0 ]
}

main "$@"
