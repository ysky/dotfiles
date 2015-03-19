# PASH
export PATH=${HOME}/bin:/sbin:/usr/sbin:/usr/local/sbin:$PATH

# bundler-exec
if [ -e ~/.zsh/bundler-exec.sh ]; then
  source ~/.zsh/bundler-exec.sh
fi

# rbenv
export RBENV_ROOT=/var/lib/rbenv
export PATH="${RBENV_ROOT}/bin:$PATH"
which rbenv > /dev/null 2>&1
if [ $? = 0 ]; then
  eval "$(rbenv init -)"
fi

# direnv
which direnv > /dev/null 2>&1
if [ $? = 0 ]; then
  eval "$(direnv hook zsh)"
fi

# 各サーバの個別設定
if [ -e ~/.zshenv_local ]; then
  source ~/.zshenv_local
fi
