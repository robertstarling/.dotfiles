#!/bin/bash

# This file is fully idempotent, so feel free to run it multiple times.

setup_bash_aliases() {
  # Check if the lines already exist to avoid duplicates
  if grep -q 'source "$HOME/.dotfiles/bash_aliases/"' "$HOME/.bash_aliases"; then
    echo "Bash aliases already set up, skipping."
    return
  fi
  echo 'source "$HOME/.dotfiles/bash_aliases/azure"' >>"$HOME/.bash_aliases"
  echo 'source "$HOME/.dotfiles/bash_aliases/devbox"' >>"$HOME/.bash_aliases"
  echo 'source "$HOME/.dotfiles/bash_aliases/utils"' >>"$HOME/.bash_aliases"
}

add_ssh_port_56312() {
  # first check if anything listenting on 56321
  if sudo ss -tuln | grep 56321; then
    echo "Port 56321 already in use, skipping SSH port addition."
    return
  fi
  sudo sed -i '/^#Port 22$/c\Port 22\nPort 56321' /etc/ssh/sshd_config
  sudo ufw allow 56321/tcp
  sudo service ssh restart
  sudo ss -tuln | grep 56321
}

main() {
  setup_bash_aliases
  add_ssh_port_56312
  echo "All setup tasks are complete! Your environment is ready to go!"
}

main
