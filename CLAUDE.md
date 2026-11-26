# CLAUDE.md

Personal dotfiles. **This repo is public**: never commit hostnames, IPs, keys,
tokens, account details, or anything describing what the machines are used for.
Machine-specific or private config belongs in untracked local files such as
`~/.zshrc.local`, which `.zshrc` sources if present.

## Layout

- `.zshrc`, `.vimrc`, `.gitconfig`: symlinked into `$HOME` by the installer
- `settings.json`: VS Code settings; linked into the VS Code Server machine
  settings when that directory exists
- `setup/install.sh`: idempotent installer (see below)
- `.vscode/dotfiles.code-workspace`: workspace file for this repo

Files in `$HOME` are symlinks into the checkout, so editing the repo changes
the live config immediately. Be careful: tools like `gh auth login` also write
into `~/.gitconfig`, which shows up as an uncommitted diff here. Do not commit
machine-specific lines such as credential helper paths.

## Environments

- **WSL (Ubuntu)**: the primary machine and the validation target. Test here.
- **Two Ubuntu VMs in Azure**: also targets. Keep everything working on plain
  Ubuntu, not just WSL. Don't assume WSL-only paths or `$WSL_DISTRO_NAME`
  without a guard.
- **An old MacBook (Homebrew)**: rarely used, probably out of date, and not
  available for testing. Much of the original config was written for it and
  later validated on WSL. macOS-specific config was removed when the repo was
  refocused on Ubuntu; it is still in git history. Don't reintroduce macOS
  code without guarding it (`[[ $OSTYPE == darwin* ]]`) and flagging that it
  is untested.

## Shell conventions

The owner is zsh-centric. Write all scripts in idiomatic zsh and apply best
practices liberally; much of the old code was written early on and shouldn't be
treated as a style guide.

- Shebang `#!/usr/bin/env zsh`; start scripts with `emulate -L zsh` and
  `setopt err_exit no_unset pipe_fail`.
- Use zsh features over external tools: `zparseopts`, `${0:A}` / `${(%):-%x}`,
  `:h :t :A` modifiers, `$+commands[cmd]` for command checks, `$path` arrays
  with `typeset -U path`, `print -u2` for stderr.
- Use `if` blocks, not `[[ ]] && cmd` (which leaves a non-zero status).
- Don't use `which`, `echo` with flags, or backticks.
- Don't name variables after zsh specials (`path`, `status`, `options`,
  `commands`) except when intentionally using them.
- Scripts that change the system must be idempotent, back up rather than
  overwrite, and support `-n` (dry run) and `-h`.
- Keep startup fast and quiet: `.zshrc` should print nothing and fail
  gracefully when optional tools or plugins are missing.

## Verifying changes

- Syntax: `zsh -n <file>`. Shellcheck does not support zsh, so don't rely on it.
- `.zshrc`: `zsh -i -c 'echo ok'` should print only `ok` and no errors.
- Installer: test with a throwaway home, never the real one:
  `HOME=$(mktemp -d) setup/install.sh`, then run it a second time to confirm
  it is a no-op. Use `-n` first.
- Never run the installer against the real `$HOME` just to see what happens.

## Git workflow

- `master` is the main branch. Work on a branch, open a PR, and squash-merge
  (history uses `Title (#N)` squash commits).
- `gh` is installed and authenticated on WSL.
- Commit only files you changed on purpose; check `git status` first, since
  `.gitconfig` may have unrelated local edits.
