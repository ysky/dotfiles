#!/bin/bash

cd $(dirname $0)

cp .gitconfig.tmpl .gitconfig

for dotfile in .?*
do
  # exclude parent dir and .git
  if [ $dotfile != ".." ] && [ $dotfile != ".git" ] && [ $dotfile != ".gitmodule" ] && [ $dotfile != ".gitconfig.tmpl" ] && [ $dotfile != ".gitmodules" ] && [ $dotfile != ".gitignore" ]
  then
    ln -Fis "$PWD/$dotfile" $HOME
  fi
done

# for nvim
mkdir -p ~/.config
ln -Fis "$PWD/.vim" ~/.config/nvim

# for git
git config --global core.excludesfile ~/.gitignore_global
