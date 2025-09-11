#!/bin/bash

# This file is fully idempotent, so feel free to run it multiple times.

setup_bash_aliases() {
  # Check if the lines already exist to avoid duplicates
  if [ -f "$HOME/.bash_aliases" ] && grep -q 'dotfiles/bash_aliases' "$HOME/.bash_aliases"; then
    echo "Bash aliases already set up, skipping."
    return
  fi

  echo 'source "$HOME/.dotfiles/bash_aliases/azure"' >>"$HOME/.bash_aliases"
  echo 'source "$HOME/.dotfiles/bash_aliases/k8s"' >>"$HOME/.bash_aliases"
  echo 'source "$HOME/.dotfiles/bash_aliases/utils"' >>"$HOME/.bash_aliases"
  echo 'source "$HOME/.dotfiles/bash_aliases/wsl"' >>"$HOME/.bash_aliases"

  echo "Bash aliases set up successfully. Log out and back in to apply changes."
}

main() {
  setup_bash_aliases
  echo "All setup tasks complete for: $0. Your environment is ready to go!"
}

main
