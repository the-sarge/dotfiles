## Markdown formatting

- Do not hard-wrap prose in Markdown or MDX files.
- Use soft-wrap style: one physical line per paragraph.
- Do not reflow prose to 80, 100, or 120 columns.
- Preserve existing Markdown semantics, including lists, tables, blockquotes, code fences, and intentional hard line breaks.
- When editing existing Markdown, do not make diff-only changes that merely rewrap paragraphs.

## Git workflow

- When working in a git repository, always develop on a feature branch.
- Before making file edits, run `git status --short --branch`.
- Any agent that may modify a git repository must work in its own dedicated worktree and feature branch, created before the first edit. Treat the initiating checkout as read-only.
- Read-only agents may share a checkout only when they use pinned commit SHAs and do not switch branches or mutate repository state.
- If currently on `main`, `master`, `trunk`, or the repo default branch, create a feature branch before editing.
- Use branch names like `codex/<short-task-slug>` unless the user gives a branch name.
- Use worktree paths like `../<repo>-<short-task-slug>` or `~/.codex/worktrees/<repo>/<short-task-slug>`.
- Before editing and immediately before committing, verify the worktree path, branch, HEAD, and cleanliness. Stop if unexpected changes are detected.
- Treat existing uncommitted changes as user-owned. Do not move, revert, stash, or overwrite them without explicit instruction.
- Never switch branches, move branch refs, reset, or clean another agent's worktree. Reuse an existing worktree only when the user explicitly directs it or the active workflow already owns it.
- Do not commit directly to the default branch.
- Do not push directly to the default branch unless the user explicitly asks for a merge or direct push.
