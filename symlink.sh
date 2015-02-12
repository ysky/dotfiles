#!/bin/bash

cd $(dirname $0)

cp .gitconfig.tmpl .gitconfig

for dotfile in .?*
do
  # exclude parent dir and .git
  if [ $dotfile != ".." ] && [ $dotfile != ".git" ] && [ $dotfile != ".gitmodule" ] && [ $dotfile != ".gitconfig.tmpl" ]
  then
    ln -Fis "$PWD/$dotfile" $HOME
  fi
done
