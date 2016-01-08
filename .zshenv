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
case ${OSTYPE} in
  darwin*)
    export GOPATH=${HOME}/.go
  ;;
  linux*)
    export GOPATH=/var/lib/go
  ;;
esac
export PATH="${GOPATH}/bin":$PATH

# direnv
which direnv > /dev/null 2>&1
if [ $? = 0 ]; then
  eval "$(direnv hook zsh)"
fi

# pyenv
case ${OSTYPE} in
  darwin*)
    export PYENV_ROOT=${HOME}/.pyenv
  ;;
  linux*)
    export PYENV_ROOT=/var/lib/pyenv
  ;;
esac

which pyenv > /dev/null
if [ $? = 0 ]; then
  eval "$(pyenv init -)"
fi

# pyenv-virtualenv
which pyenv-virtual-init > /dev/null
if [ $? = 0 ]; then
  eval "$(pyenv virtualenv-init -)"
fi

# nodebew
export NODEBREW_ROOT="${HOME}/.nodebrew"
export PATH="${NODEBREW_ROOT}/current/bin:${PATH}"

# 各サーバの個別設定
if [ -e ~/.zshenv_local ]; then
  source ~/.zshenv_local
fi
