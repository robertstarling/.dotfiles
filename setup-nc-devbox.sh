#!/bin/bash

# This file is fully idempotent, so feel free to run it multiple times.

# Usage:
#   ./setup-nc-devbox.sh DEVBOX_RESOURCE_GROUP

setup_bash_aliases() {
  local devboxRG="$1"
  local filename="$HOME/.bash_aliases"
  # Check if the lines already exist to avoid duplicates
  if [ -f "$filename" ] && grep -q 'dotfiles/bash_aliases' "$filename"; then
    echo "Bash aliases already set up, skipping."
    return
  fi
  echo 'source "$HOME/.dotfiles/bash_aliases/azure"'     >>"$filename"
  echo 'source "$HOME/.dotfiles/bash_aliases/utils"'     >>"$filename"  
  echo 'source "$HOME/.dotfiles/bash_aliases/devbox"'    >>"$filename"
  echo 'source "$HOME/.dotfiles/bash_aliases/devbox-go"' >>"$filename"
  echo "export devboxRG=$devboxRG"                       >>"$filename"

  echo "Bash aliases set up successfully. Log out and back in to apply changes, or source $filename"
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

main() {
  local devboxRG="$1"
  setup_bash_aliases $devboxRG
  add_ssh_port_56312
  setup_devbox_config $devboxRG
  echo "All setup tasks complete for: $0. Your environment is ready to go!"
}

main "$1"
