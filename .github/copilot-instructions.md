# Copilot Instructions

## Architecture

This is a personal dotfiles repository that bootstraps Linux development environments. It has three layers:

1. **Setup scripts** (root `setup*.sh`) — Entry points that orchestrate installation. There are environment-specific variants:
   - `setup.sh` — Base setup (tmux, Azure CLI, SSH key, shared repo config)
   - `setup-common.sh` — Minimal setup (tmux only, creates GitHub SSH key)
   - `setup-nc-devbox.sh` — Azure devbox additions (bash aliases, gnome-keyring, MCP links, SSH port)
   - `setup-wsl.sh` — WSL-specific bash aliases

2. **Installer scripts** (`src/install_*.sh`) — Each installs one tool idempotently. Called by setup scripts, not directly.

3. **Config files** (`links/`) — Dotfile configs (tmux, nvim, git, shell helpers, etc.) that get symlinked into `$HOME` by `src/linkdotfiles/`.

## Key Conventions

- **All setup and installer scripts must be idempotent** — safe to run multiple times without side effects.
- **Installer scripts write to stdout/stderr only** — setup scripts capture their output to temp log files under `/tmp/setup_logs.XXXXXX/`.
- **Symlink management** is handled by a Go program at `src/linkdotfiles/`. It maps directories in `links/` to paths under `$HOME`. To add a new dotfile link, add it to the `Links` slice in `src/linkdotfiles/config.go` and rebuild the binary.
- **Shell scripts use `#!/bin/bash`** and source the shared logger from `src/lib/log.sh`.
- **Git submodules** are used for tmux plugin manager (tpm).
- **Machine-local overrides** use `localrc` (shell) and `local_gitconfig` (git) — both gitignored.

## Build

The linkdotfiles tool is a Go module at `src/linkdotfiles/`:

```sh
cd src/linkdotfiles && go build -o linkdotfiles .
```
