#!/bin/bash

# This file is fully idempotent, so feel free to run it multiple times.

source "$HOME/.dotfiles/links/zsh/utils/output/log.sh"

prevent_apt_daemon_restart_prompts() {
  sudo sed -i "s/^#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
}

install_components() {
  # TODO: Turn these into a DAG and install everything concurrently.
  local components=(
    "$HOME/.dotfiles/src/install_tmux.sh"
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

link_dotfiles() {
  # TODO: Just `go run` this. Currently, I need to rebuild the binary every time I
  # adjust my dotfile links.
  "$HOME/.dotfiles/src/linkdotfiles/linkdotfiles"
}

main() {
  create_github_ssh_key_if_missing

  export PATH="$PATH:/usr/local/go/bin"
  export PATH="$PATH:$HOME/.local/bin"

  prevent_apt_daemon_restart_prompts
  install_components
  link_dotfiles
  
  log "All $0 setup tasks complete. Your environment is ready to go!"
}

main
