#!/bin/bash

cd $(dirname $0)

for dotfile in .?*
do
  # exclude parent dir and .git
  if [ $dotfile != ".." ] && [ $dotfile != ".git" ] && [ $dotfile != ".gitmodule" ]
  then
    ln -Fis "$PWD/$dotfile" $HOME
  fi
done
