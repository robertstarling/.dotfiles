```
cd "$HOME"
git clone https://github.com/robertstarling/.dotfiles
cd .dotfiles
git remote set-url origin git@github.com:robertstarling/.dotfiles

# Choose one or more of the setup scripts to run..
./setup-common.sh
./setup-nc-devbox.sh robstarling-2509
./setup-wsl.sh

# TODO
# - helm
# - gopls
```
