#!/bin/bash

setup_nc_devbox_bash_aliases() {
  echo 'source "$HOME/.dotfiles/bash_aliases/azure"' >>"$HOME/.bash_aliases"
  echo 'source "$HOME/.dotfiles/bash_aliases/devbox"' >>"$HOME/.bash_aliases"
  echo 'source "$HOME/.dotfiles/bash_aliases/utils"' >>"$HOME/.bash_aliases"
}

main() {
  setup_nc_devbox_bash_aliases
  echo "All setup tasks are complete! Your environment is ready to go!"
}

main
