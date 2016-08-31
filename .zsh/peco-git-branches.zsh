function peco-git-branches(){
  local res=$(git branch -a | sed 's/^\*/ /'| awk '{ print $1 }' | peco)
  BUFFER+=$res
  zle clear-screen
}

zle -N peco-git-branches
bindkey '^b' peco-git-branches
