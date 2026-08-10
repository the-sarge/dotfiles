# dotfiles

Personal config managed with [GNU stow](https://www.gnu.org/software/stow/) +
git. Each top-level directory is a stow "package" whose contents mirror the
layout under `$HOME` — `git/.gitconfig` becomes `~/.gitconfig`,
`broot/.config/broot/` becomes `~/.config/broot/`, etc.

## Fresh-machine bootstrap

```bash
# 1. Install stow
brew install stow                       # macOS
# sudo apt install stow                 # Debian/Ubuntu

# 2. Clone
git clone git@github.com:<user>/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 3. Stow the packages you want (or all of them)
for pkg in bash zsh git ssh tmux helix nvim zellij smug \
           starship broot btop ccstatusline gh ghostty \
           agents claude codex; do
  stow "$pkg"
done
```

Stow will refuse if a target file already exists and isn't owned by stow.
Resolve by either deleting the existing file or moving it into the package
first (see `bin/migrate-config-to-stow.sh` for the pattern).

## Packages

### Stowed into `$HOME` directly

| Package      | Provides                                   |
| ------------ | ------------------------------------------ |
| `bash`       | `.bash_profile`, `.bashrc`                 |
| `zsh`        | `.zshrc`                                   |
| `tcsh`       | `.tcshrc` (legacy, rarely used)            |
| `git`        | `.gitconfig`, `.gitignore`                 |
| `ssh`        | `.ssh/config`                              |
| `tmux`       | `.tmux.conf` (TPM plugins not tracked)     |
| `nvim`       | `.viminfo` (legacy)                        |
| `agents`     | `.agents/` (shared instructions)           |
| `claude`     | `.claude/CLAUDE.md` (shared link)          |
| `codex`      | `.codex/AGENTS.md` (shared link)           |

### Stowed under `~/.config/`

| Package        | Target                       |
| -------------- | ---------------------------- |
| `broot`        | `~/.config/broot/`           |
| `btop`         | `~/.config/btop/`            |
| `ccstatusline` | `~/.config/ccstatusline/`    |
| `gh`           | `~/.config/gh/config.yml` (only — `hosts.yml` stays per-machine, contains auth) |
| `ghostty`      | `~/.config/ghostty/`         |
| `git` (addon)  | `~/.config/git/{allowed_signers,ignore}` |
| `helix`        | `~/.config/helix/config.toml` |
| `nvim`         | `~/.config/nvim/`            |
| `smug`         | `~/.config/smug/`            |
| `starship`     | `~/.config/starship.toml`    |
| `zellij`       | `~/.config/zellij/`          |

## Per-machine bits NOT in this repo

These either contain secrets, machine-state, or are best regenerated locally.
Set them up by hand on each machine:

- **conda/anaconda**: run `conda init bash` and `conda init zsh` after installing.
  These write `>>> conda initialize >>>` blocks with paths specific to the
  machine's anaconda install — keeping them in dotfiles fights the tool.
- `~/.config/gh/hosts.yml` — `gh auth login` writes this
- `~/.config/1Password/`, `~/.config/gcloud/`, `~/.config/github-copilot/` — auth state
- `~/.config/iterm2/` — iTerm2 prefs (`~/Library/Application Support/iTerm2`)
- `~/.config/karabiner/` — keyboard remapping (machine-specific)
- `~/.config/{cagent,chezmoi,cmux,darktable,offload,opencode,zed}` — runtime state
- `~/.ssh/{id_*,known_hosts}` — keys and host fingerprints

## Cross-machine portability notes

- **Homebrew prefix**: Apple Silicon installs to `/opt/homebrew`, Intel to
  `/usr/local`. Shell init in `zsh/.zprofile` probes both and picks whichever
  exists. Anything else that needs the prefix should reference `$HOMEBREW_PREFIX`
  (set by `brew shellenv`) rather than hardcoding either path.
- **`$HOME` paths**: use `~` or `$HOME`, never `/Users/josh`. Configs that
  require an absolute path (e.g. `git`'s `allowedSignersFile`) should use `~`,
  which Git expands. Test with `git config --get <key>` to confirm.

## Tooling

- `bin/migrate-config-to-stow.sh` — moves `~/.config/<name>/` directories
  into stow-managed packages; run with `DRY_RUN=0` to actually execute.
  Safe by default; rolls back on any per-package failure.
