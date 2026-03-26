```sh
cd "$HOME"
git clone https://github.com/robertstarling/.dotfiles
cd .dotfiles
git remote set-url origin git@github.com:robertstarling/.dotfiles

# Base setup
./setup.sh

# Base setup + WSL-specific config
# Also installs Go if /usr/local/go is not already present.
./setup.sh wsl

# Base setup + nc-devbox-specific config
./setup.sh nc-devbox robstarling-2509

# TODO
# - helm
# - gopls
```
