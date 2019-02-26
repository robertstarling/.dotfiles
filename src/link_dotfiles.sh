#!/bin/bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/.dotfiles
############################

########## Variables
set -x

links_dir=$HOME/.dotfiles/links                    # dotfiles directory
olddir=$HOME/.backup_dotfiles          # old dotfiles backup directory
#TODO: This is really just all of the files in ~/.dotfiles/links
files=(profile bashrc sh_aliases vim vimrc inputrc gitconfig funcs zshrc tmux.conf Xresources)    # list of files/folders to symlink in homedir
##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in $HOME ..."
rm -rf $olddir
mkdir -p $olddir

# Delete oldfiles, move any existing dotfiles in homedir to dotfiles_old
# directory, then create symlinks from the homedir to any files in the
# $HOME/dotfiles directory specified in $files
echo "Moving any existing dotfiles from $HOME to $olddir"
for file in ${files[*]}; do
    if [ -h $HOME/.$file ]; then
        rm $HOME/.$file
    elif [ -e $HOME/.$file ]; then
        mv -f $HOME/.$file $olddir
    fi
    echo "Creating symlink to $file in home directory."
    ln -s $links_dir/$file $HOME/.$file
done

# Create the vim directories
echo "Creating vim undo directory ..."
mkdir -p $HOME/.vim/undo

echo "done"
set +x
