```
sudo apt-get install curl
curl -s https://raw.githubusercontent.com/robertstarling/.dotfiles/master/src/install_git | bash
cd "$HOME"
git clone https://github.com/robertstarling/.dotfiles
cd .dotfiles
git remote set-url origin git@github.com:robertstarling/.dotfiles
source source_me
```
