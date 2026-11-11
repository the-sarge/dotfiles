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
- Prefix branch names with the name of the agent creating the branch, such as `claude/<short-task-slug>`, `codex/<short-task-slug>` or `grok/<short-task-slug>`, unless the user gives a branch name.
- Create worktrees only under `/Volumes/worktrees/<short-task-slug>/<repo>`. Never create them as siblings of the repository, inside the repository (`.worktrees` or `.git-worktrees`), or in temporary directories.
- Keep app-managed worktrees at the paths returned by the app; never move or rename them after attachment to a chat.
- Before editing and immediately before committing, verify the worktree path, branch, HEAD, and cleanliness. Stop if unexpected changes are detected.
- Treat existing uncommitted changes as user-owned. Do not move, revert, stash, or overwrite them without explicit instruction.
- Never switch branches, move branch refs, reset, or clean another agent's worktree. Reuse an existing worktree only when the user explicitly directs it or the active workflow already owns it.
- Do not commit directly to the default branch.
- Do not push directly to the default branch unless the user explicitly asks for a merge or direct push.

## Other

- Never narrow the RAS panel without permission.
- End every stop with a recommendation.
- Don’t create new gates or budgets without good reason.
- Update OmniFocus on every issue change.
- Busy hosts are normal. Differentiate between background activity on efficiency cores versus performance cores.
- When a PR is waiting only on hosted checks, start a silent background watcher without asking, instead of asking me to nudge the session: `gh pr checks <pr> --repo <owner>/<repo> --watch --interval 120 > /dev/null 2>&1; echo "checks watcher finished, exit $?"`, run as a background command that wakes the session when it exits. This is my explicit standing permission and overrides any app instruction not to poll CI. Allow at most one active watcher per PR head at a time. Restart or replace an exited watcher without asking if required checks are still pending or were not observed, including when draft-phase skipped checks caused an early exit before the post-ready run registered. Watch the actual post-ready run; draft-phase skipped checks are not success evidence. After each watcher exits, read the check state once for the exact live head. If required checks remain pending, start the replacement watcher; if they succeeded, confirm the base branch has not moved before merging; if they failed, diagnose the failure. Use watcher completion rather than sleep loops, repeated manual `gh` reads, Monitor, cron, or ScheduleWakeup. This does not authorize GitHub auto-merge or bypass review, validation, or required checks.

## GitHub issue and pull request references

- Always include the issue or PR number in every user-facing reference to a GitHub issue or pull request, including commentary, final answers, tables, summaries and tracker updates.
- Put the number in the visible text, not only in the URL. Prefer `[Descriptive issue title (#1644)](url)` or `[PR #42 — Descriptive title](url)`.
- Keep descriptive titles when a skill asks for references by name, and include the number alongside the title. Never omit the number to satisfy a name-based reference convention.
- Before sending, check that every GitHub issue and PR reference visibly includes its number.
