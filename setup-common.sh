#!/bin/bash

# This file is fully idempotent, so feel free to run it multiple times.

create_github_ssh_key_if_missing() {
  if [ ! -f "$HOME/.ssh/id_ed25519_github" ]; then
    ssh-keygen -t ed25519 -C "rob@nc-devbox-2509" -f "$HOME/.ssh/id_ed25519_github"
    ssh-add "$HOME/.ssh/id_ed25519_github"
    echo "Add public key to GitHub → Settings → SSH and GPG keys → New SSH key:"
    cat  "$HOME/.ssh/id_ed25519_github.pub"
    echo 
    echo "Then confirm access with: ssh -T git@github.com"
  ;fi
}

main() {
  create_github_ssh_key_if_missing
  echo "All $0 setup tasks complete. Your environment is ready to go!"
}

main
