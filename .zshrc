# vim: foldmethod=marker
# vim: foldcolumn=3
# vim: foldlevel=0

#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

autoload -U compinit
compinit

#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

## keep background processes at full speed
setopt NOBGNICE
## restart running processes on exit
#setopt HUP

# zsh version info
autoload -Uz is-at-least

setopt extended_glob

# history {{{
HISTFILE=~/.zsh_history
HISTSIZE=500000
SAVEHIST=500000
DIRSTACKSIZE=100

#setopt APPEND_HISTORY
## for sharing history between zsh processes
#setopt INC_APPEND_HISTORY
#setopt SHARE_HISTORY
# ignore duplication command history list
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_expire_dups_first
setopt hist_reduce_blanks
setopt extended_history
setopt inc_append_history
# }}}

## never ever beep ever
setopt NO_BEEP

autoload -U colors
colors

DIRSTACKSIZE=100
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

autoload -Uz compinit && compinit

# prompt {{{
setopt prompt_subst
PROMPT="%(?.%{%}.%{${fg[red]}%})[%n@%m]%{${reset_color}%}%# "
RPROMPT="[%~]"
REPORTTIME=3

# コマンド実行後にプロンプトを消す
setopt transient_rprompt

# vcs_info
if is-at-least 4.3.10; then
  autoload -Uz vcs_info
  zstyle ':vcs_info:git:*' check-for-changes true
  zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
  zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
  zstyle ':vcs_info:*'     formats "%F{green}%c%u[%b]%f"
  zstyle ':vcs_info:*'     actionformats '[%b|%a]'
  precmd () { vcs_info }
  RPROMPT='${vcs_info_msg_0_}'${RPROMPT}
fi
# }}}

# 履歴の前方一致検索
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

bindkey "^A" beginning-of-line
bindkey "^E" end-of-line

zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' keep-prefix
zstyle ':completion:*:default' list-colors ''
zstyle ':completion:*' verbose yes
setopt list_types

# share command history data
setopt share_history

# correct wrong command
setopt correct

# slim list
setopt list_packed

setopt auto_pushd
setopt pushd_ignore_dups

setopt long_list_jobs

# show even if there is no newline
#unsetopt promptcr

export LANG=ja_JP.utf-8
export TERM=xterm
export LESS='-c -i -X -R -F'

# kill terminal lock
stty stop undef

# alias {{{
case ${OSTYPE} in
  darwin*)
    alias ll='ls -lG'
    alias lla='ls -laG'
    ;;
  linux*)
    alias ll='ls -l --color=tty'
    alias lla='ls -la --color=tty'
    ;;
esac
if [ -e /usr/local/bin/vim ]; then
  alias vi='/usr/local/bin/vim'
  export EDITOR=/usr/local/bin/vim
else
  alias vi='vim'
  export EDITOR=vim
fi

alias grep='grep --color=auto'
alias rmrf='rm -rf'
alias ctags='ctags -f .tags'

if which gtags > /dev/null 2>&1; then
  alias gtags="gtags --gtagslabel=pygments"
fi
# }}}
# auto ls {{{
# cd するたびにllをたたく.ただし50個以上項目がある場合は個数の表示にとどめる
function chpwd() {
  if [ $(ls -l | wc -l) -le 50 ]; then
    case ${OSTYPE} in
      darwin*); ls -Gl;;
      linux*);  ls -l --color=tty;;
    esac
  else
    echo "$(ls -l | wc -l) items exist in `pwd`"
  fi
}
# }}}
# antigen {{{
if [ -e ~/.zsh/antigen.zsh ]; then
  source ~/.zsh/antigen.zsh
  antigen bundle mollifier/anyframe
  antigen apply

  bindkey "^r" anyframe-widget-put-history
  bindkey "^k" anyframe-widget-kill
fi
# }}}
# include {{{
if [ -e ~/.zsh/git-completion.bash ]; then
  source ~/.zsh/git-completion.bash
fi

if [ -e ~/.zsh/complete-mackerel-host-ip.zsh ]; then
  source ~/.zsh/complete-mackerel-host-ip.zsh
fi

if [ -e ~/.zshrc_local ]; then
  source ~/.zshrc_local
fi
# }}}
