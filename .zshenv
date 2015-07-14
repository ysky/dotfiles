# PASH
export PATH=${HOME}/bin:${HOME}/.bin:/sbin:/usr/sbin:/usr/local/sbin:$PATH

# rbenv
case ${OSTYPE} in
  darwin*)
    export RBENV_ROOT=${HOME}/.rbenv
  ;;
  linux*)
    export RBENV_ROOT=/var/lib/rbenv
  ;;
esac
export PATH="${RBENV_ROOT}/bin:$PATH"
which rbenv > /dev/null 2>&1
if [ $? = 0 ]; then
  eval "$(rbenv init -)"
fi

# go
export GOPATH=/var/lib/go
export PATH="${GOPATH}/bin":$PATH

# direnv
which direnv > /dev/null 2>&1
if [ $? = 0 ]; then
  eval "$(direnv hook zsh)"
fi

# 各サーバの個別設定
if [ -e ~/.zshenv_local ]; then
  source ~/.zshenv_local
fi
