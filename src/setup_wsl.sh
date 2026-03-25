#!/bin/bash

# This file is fully idempotent, so feel free to run it multiple times.

setup_bash_aliases() {
  local filename="$HOME/.bash_aliases"
  local added=0

  local entries=(
    'source "$HOME/.dotfiles/bash_aliases/azure"'
    'source "$HOME/.dotfiles/bash_aliases/utils"'
    'source "$HOME/.dotfiles/bash_aliases/common"'
    'source "$HOME/.dotfiles/bash_aliases/common-go"'
    'source "$HOME/.dotfiles/bash_aliases/wsl"'
  )

  for entry in "${entries[@]}"; do
    if ! grep -qF "$entry" "$filename" 2>/dev/null; then
      echo "$entry" >>"$filename"
      ((added++))
    fi
  done

  if [ "$added" -gt 0 ]; then
    echo "Added $added entries to $filename. Log out and back in to apply changes, or source $filename"
  else
    echo "Bash aliases already set up, skipping."
  fi
}

install_packages() {
  sudo apt-get install -y -q \
    socat \
    ;
}

setup_git_credential_helper() {
  local gcm="/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"
  local xdg_git_config="${XDG_CONFIG_HOME:-$HOME/.config}/git/config"
  if [ ! -f "$gcm" ]; then
    echo "WARNING: git-credential-manager.exe not found at $gcm"
    echo "Install Git for Windows to get it, then re-run this script."
    return 1
  fi

  mkdir -p "$(dirname "$xdg_git_config")"
  git config --file "$xdg_git_config" credential.helper "!\"$gcm\""
  git config --file "$xdg_git_config" credential.https://dev.azure.com.useHttpPath true
  echo "Git credential helper configured in $xdg_git_config to use Windows GCM."
}

setup_passwordless_sudo() {
  local sudoers_file="/etc/sudoers.d/$USER"
  if [ -f "$sudoers_file" ]; then
    echo "Passwordless sudo already configured, skipping."
    return
  fi
  echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee "$sudoers_file" >/dev/null
  sudo chmod 0440 "$sudoers_file"
  echo "Passwordless sudo configured for $USER."
}

setup_inotify_limits() {
  local conf="/etc/sysctl.d/90-override.conf"
  if [ -f "$conf" ] && grep -q "max_user_watches=524288" "$conf"; then
    echo "inotify limits already configured, skipping."
    return
  fi
  echo -e "fs.inotify.max_user_watches=524288\nfs.inotify.max_user_instances=512" | sudo tee "$conf" >/dev/null
  sudo sysctl -p "$conf"
  echo "inotify limits configured (watches=524288, instances=512)."
}

install_docker() {
  if command -v docker &>/dev/null; then
    echo "Docker already installed, skipping."
    return
  fi
  bash "$HOME/.dotfiles/src/install_docker.sh"
}

main() {
  setup_passwordless_sudo
  setup_bash_aliases
  install_packages
  setup_git_credential_helper
  setup_inotify_limits
  install_docker
  echo "All setup tasks complete for: $0. Your environment is ready to go!"
}

main
