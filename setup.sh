#!/bin/bash

# This file is fully idempotent, so feel free to run it multiple times.
#
# Usage:
#   ./setup.sh              # Base setup (tmux, SSH key, dotfile links)
#   ./setup.sh wsl           # Base setup + WSL-specific config
#   ./setup.sh nc-devbox RG  # Base setup + Azure devbox config (RG = resource group)

source "$HOME/.dotfiles/src/lib/log.sh"

usage() {
  echo "Usage: $0 [wsl | nc-devbox DEVBOX_RESOURCE_GROUP]"
  echo
  echo "Options:"
  echo "  (none)                 Base setup: tmux, GitHub SSH key, dotfile links"
  echo "  wsl                    Base setup + WSL environment (socat, Windows GCM)"
  echo "  nc-devbox RG           Base setup + Azure devbox (bash aliases, gnome-keyring, SSH port, MCP links)"
  exit 1
}

prevent_apt_daemon_restart_prompts() {
  sudo sed -i "s/^#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
}

install_components() {
  # TODO: Turn these into a DAG and install everything concurrently.
  local components=(
    "$HOME/.dotfiles/src/install_essentials.sh"
    "$HOME/.dotfiles/src/install_az.sh"
    # "$HOME/.dotfiles/src/update_git_submodules.sh"
    # "$HOME/.dotfiles/src/install_go.sh"
    # "$HOME/.dotfiles/src/install_fzf.sh"
    # "$HOME/.dotfiles/src/install_fd.sh"
    # "$HOME/.dotfiles/src/remap_capslock.sh"
    # "$HOME/.dotfiles/src/install_node.sh"
    # "$HOME/.dotfiles/src/install_delta.sh"
    # "$HOME/.dotfiles/src/install_lazygit.sh"
    # "$HOME/.dotfiles/src/install_neovim.sh"
    # "$HOME/.dotfiles/src/install_tmux.sh"  # nc-devbox only; see src/setup_nc_devbox.sh
    # "$HOME/.dotfiles/src/install_zoxide.sh"
    # "$HOME/.dotfiles/src/install_sesh.sh"
    # "$HOME/.dotfiles/src/install_docker.sh"
    # "$HOME/.dotfiles/src/install_opencode.sh"
  )

  log_dir=$(mktemp -d /tmp/setup_logs.XXXXXX)

  for component in "${components[@]}"; do
    script_name=$(basename "$component")
    log_file="$log_dir/$script_name.log"
    log "🚀 Running script: $script_name"
    if ! bash "$component" >"$log_file" 2>&1; then
      log "❌ Script $script_name failed. Check the log at $log_file for details."
    fi
  done

  log "Logs saved to: $log_dir"
}

create_github_ssh_key_if_missing() {
  if [ -f "$HOME/.ssh/id_ed25519_github" ]; then
    echo "GitHub SSH key already exists, skipping."
    return
  fi
  ssh-keygen -t ed25519 -C "rob@$(hostname)" -f "$HOME/.ssh/id_ed25519_github"
  ssh-add "$HOME/.ssh/id_ed25519_github"
  echo "Add public key to GitHub → Settings → SSH and GPG keys → New SSH key:"
  cat  "$HOME/.ssh/id_ed25519_github.pub"
  echo 
  echo "Then confirm access with: ssh -T git@github.com"
  echo "Then switch to ssh authentication: "
  echo "  git remote -v"
  echo "  git remote set-url origin git@github.com:robertstarling/.dotfiles"
}

configure_dotfiles_git_identity() {
  local dotfiles_gitconfig="$HOME/.dotfiles/local_gitconfig"

  if ! git -C "$HOME/.dotfiles" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return
  fi

  if ! git -C "$HOME/.dotfiles" config --local --get-all include.path | grep -Fxq "$dotfiles_gitconfig"; then
    git -C "$HOME/.dotfiles" config --local --add include.path "$dotfiles_gitconfig"
  fi

  git -C "$HOME/.dotfiles" config --local --unset-all user.name >/dev/null 2>&1 || true
  git -C "$HOME/.dotfiles" config --local --unset-all user.email >/dev/null 2>&1 || true
}

report_git_identity_settings() {
  local dotfiles_gitconfig="$HOME/.dotfiles/local_gitconfig"
  local dotfiles_name
  local dotfiles_email
  local global_name
  local global_email

  dotfiles_name=$(git config -f "$dotfiles_gitconfig" --get user.name 2>/dev/null || true)
  dotfiles_email=$(git config -f "$dotfiles_gitconfig" --get user.email 2>/dev/null || true)
  global_name=$(git config --global --get user.name 2>/dev/null || true)
  global_email=$(git config --global --get user.email 2>/dev/null || true)

  log ".dotfiles repo git identity comes from $dotfiles_gitconfig"
  log ".dotfiles user.name: ${dotfiles_name:-<unset>}"
  log ".dotfiles user.email: ${dotfiles_email:-<unset>}"
  log "Update $dotfiles_gitconfig if you want different values for the .dotfiles repo."

  log "Global git identity for repos outside .dotfiles:"
  log "global user.name: ${global_name:-<unset>}"
  log "global user.email: ${global_email:-<unset>}"
  log "Update them with: git config --global user.name \"Your Name\""
  log "and: git config --global user.email \"you@example.com\""
}

link_tmux_config() {
  mkdir -p "$HOME/.config"
  ln -sfn "$HOME/.dotfiles/links/tmux" "$HOME/.config/tmux"
}

main() {
  local env="${1:-}"
  local devbox_rg="${2:-}"

  case "$env" in
    ""|wsl|nc-devbox) ;;
    -h|--help|help) usage ;;
    *) echo "Unknown environment: $env"; usage ;;
  esac

  if [ "$env" = "nc-devbox" ] && [ -z "$devbox_rg" ]; then
    echo "Error: nc-devbox requires a resource group argument."
    usage
  fi

  create_github_ssh_key_if_missing

  export PATH="$PATH:/usr/local/go/bin"
  export PATH="$PATH:$HOME/.local/bin"

  prevent_apt_daemon_restart_prompts
  install_components
  link_tmux_config
  configure_dotfiles_git_identity
  report_git_identity_settings

  # Environment-specific setup
  if [ "$env" = "wsl" ]; then
    log "Running WSL-specific setup..."
    bash "$HOME/.dotfiles/src/setup_wsl.sh"
  elif [ "$env" = "nc-devbox" ]; then
    log "Running nc-devbox-specific setup..."
    bash "$HOME/.dotfiles/src/setup_nc_devbox.sh" "$devbox_rg"
  fi

  log "🎉✨ All setup tasks are complete! Your environment is ready to go! 🚀"
}

main "$@"
