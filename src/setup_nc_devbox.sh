#!/bin/bash

# This file is fully idempotent, so feel free to run it multiple times.

# Usage:
#   ./setup-nc-devbox.sh DEVBOX_RESOURCE_GROUP

setup_bash_aliases() {
  local devboxRG="$1"
  local filename="$HOME/.bash_aliases"
  local added=0

  local entries=(
    'source "$HOME/.dotfiles/bash_aliases/azure"'
    'source "$HOME/.dotfiles/bash_aliases/utils"'
    'source "$HOME/.dotfiles/bash_aliases/common"'
    'source "$HOME/.dotfiles/bash_aliases/common-go"'
    'source "$HOME/.dotfiles/bash_aliases/devbox"'
    'source "$HOME/.dotfiles/bash_aliases/devbox-go"'
    'source "$HOME/.dotfiles/bash_aliases/gnome-keyring"'
    "export devboxRG=$devboxRG"
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

# Symlink .vscode/mcp.json in each repo to the global MCP config in dotfiles.
# This gives VS Code Copilot Chat access to the same MCP servers across all repos.
setup_vscode_mcp_links() {
  local mcp_source="$HOME/.dotfiles/links/mcp.json"
  if [ ! -f "$mcp_source" ]; then
    echo "No global mcp.json found at $mcp_source, skipping VS Code MCP setup."
    return
  fi

  local linked=0
  for repo_dir in "$HOME"/nc-*; do
    [ -d "$repo_dir/.git" ] || continue
    mkdir -p "$repo_dir/.vscode"
    if [ ! -L "$repo_dir/.vscode/mcp.json" ]; then
      ln -sf "$mcp_source" "$repo_dir/.vscode/mcp.json"
      ((linked++))
    fi
  done

  if [ "$linked" -gt 0 ]; then
    echo "Linked .vscode/mcp.json in $linked repo(s) to $mcp_source"
  fi
}

# Alternative secure inbound SSH port from dynamic TCP range
# (May also need to update Azure Network Security Group to allow inbound on this port) e.g.
# [robstarling Sep2025] provide secure alternative SSH port filtered by source IP
add_ssh_port_56312() {
  # first check if anything listening on 56321
  if sudo ss -tuln | grep 56321; then
    echo "Port 56321 already in use, skipping SSH port addition."
    return
  fi
  sudo sed -i '/^#Port 22$/c\Port 22\nPort 56321' /etc/ssh/sshd_config
  sudo ufw allow 56321/tcp
  sudo service ssh restart
  sudo ss -tuln | grep 56321
}

setup_devbox_config() {
  # Check if the lines already exist to avoid duplicates
  filename="$HOME/.config/nc-devbox/config.yaml"
  if [ -f "$filename" ]; then
    echo "$filename already exists, skipping."
    return
  fi
  cp "$HOME/nc-devbox/docs/examples/config.yaml" "$filename"
  sed -i "s/resource_group: .*/resource_group: $1/" "$filename"
  sed -i 's/time_to_live: .*/time_to_live: "1 month"/' "$filename"
  echo "Successfully added overrides:"
  diff "$HOME/nc-devbox/docs/examples/config.yaml" "$filename"
  echo 
  echo "Verify with: vm status"
}

# Configure GPG for headless SSH use: cache credentials for a full work day,
# use pinentry-tty (avoids curses hangs), and enable loopback pinentry mode.
setup_gpg_config() {
  local gpg_agent_conf="$HOME/.gnupg/gpg-agent.conf"
  local gpg_conf="$HOME/.gnupg/gpg.conf"
  local gpg_agent_ttl=$((14 * 60 * 60))

  mkdir -p "$HOME/.gnupg"
  chmod 700 "$HOME/.gnupg"
  touch "$gpg_agent_conf"
  touch "$gpg_conf"

  ensure_gpg_agent_setting() {
    local key="$1" value="$2" conf="$3"
    if grep -q "^$key " "$conf" 2>/dev/null; then
      sed -i "s|^$key .*|$key $value|" "$conf"
    else
      printf '%s %s\n' "$key" "$value" >> "$conf"
    fi
  }

  ensure_gpg_agent_setting "default-cache-ttl" "$gpg_agent_ttl" "$gpg_agent_conf"
  ensure_gpg_agent_setting "max-cache-ttl" "$gpg_agent_ttl" "$gpg_agent_conf"

  if command -v pinentry-tty >/dev/null 2>&1; then
    ensure_gpg_agent_setting "pinentry-program" "$(command -v pinentry-tty)" "$gpg_agent_conf"
  fi

  if ! grep -q "^allow-loopback-pinentry" "$gpg_agent_conf" 2>/dev/null; then
    printf '%s\n' "allow-loopback-pinentry" >> "$gpg_agent_conf"
  fi

  if ! grep -q "^pinentry-mode loopback" "$gpg_conf" 2>/dev/null; then
    printf '%s\n' "pinentry-mode loopback" >> "$gpg_conf"
  fi

  if command -v gpg-connect-agent >/dev/null 2>&1; then
    gpg-connect-agent reloadagent /bye >/dev/null 2>&1 || true
  fi

  echo "GPG config updated."
}

install_gnome_keyring() {
  if dpkg -s gnome-keyring libsecret-1-0 dbus-x11 &>/dev/null; then
    echo "gnome-keyring already installed, skipping."
    return
  fi
  sudo apt-get update -qq && sudo apt-get install -y -qq gnome-keyring libsecret-1-0 dbus-x11
  echo "gnome-keyring installed successfully."
}

install_tmux() {
  local log_dir=$(mktemp -d /tmp/setup_logs.XXXXXX)
  local log_file="$log_dir/install_tmux.sh.log"
  echo "Installing tmux from source..."
  if ! bash "$HOME/.dotfiles/src/install_tmux.sh" >"$log_file" 2>&1; then
    echo "tmux install failed. Check log: $log_file"
    return 1
  fi
  echo "tmux installed successfully."
}

main() {
  local devboxRG="$1"
  setup_bash_aliases $devboxRG
  install_tmux
  setup_vscode_mcp_links
  setup_gpg_config
  install_gnome_keyring
  add_ssh_port_56312
  setup_devbox_config $devboxRG
  echo "All setup tasks complete for: $0. Your environment is ready to go!"
}

main "$1"
