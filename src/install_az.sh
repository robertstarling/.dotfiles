#!/bin/bash

main() {
  # Skip if a Linux-native az CLI is already installed.
  # On WSL the Windows az (under /mnt/c/...) doesn't count — it can't talk to
  # the Linux Docker daemon, which breaks `az acr login`.
  if command -v az &>/dev/null && [[ "$(command -v az)" != /mnt/* ]]; then
    echo "Linux-native az CLI already installed, skipping."
    return
  fi
  delete_az
  install_az
  az version
}

delete_az() {
  sudo apt-get remove -y azure-cli
}

install_az() {
  # Update package index and install Azure CLI
  curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
  sudo apt-get update
  sudo apt-get install -y azure-cli
}

main
