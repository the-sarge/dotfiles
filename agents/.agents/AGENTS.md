## Markdown formatting

- Do not hard-wrap prose in Markdown or MDX files.
- Use soft-wrap style: one physical line per paragraph.
- Do not reflow prose to 80, 100, or 120 columns.
- Preserve existing Markdown semantics, including lists, tables, blockquotes, code fences, and intentional hard line breaks.
- When editing existing Markdown, do not make diff-only changes that merely rewrap paragraphs.

## Git workflow

- When working in a git repository, always develop on a feature branch.
- Before making file edits, run `git status --short --branch`.
- If currently on `main`, `master`, `trunk`, or the repo default branch, create a feature branch before editing.
- Prefer a separate git worktree for non-trivial changes, review loops, experiments, or when the current checkout has uncommitted changes.
- Use branch names like `codex/<short-task-slug>` unless the user gives a branch name.
- Use worktree paths like `../<repo>-<short-task-slug>` or `~/.codex/worktrees/<repo>/<short-task-slug>`.
- Treat existing uncommitted changes as user-owned. Do not move, revert, stash, or overwrite them without explicit instruction.
- Do not commit directly to the default branch.
- Do not push directly to the default branch unless the user explicitly asks for a merge or direct push.
