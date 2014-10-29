# Automatically run Ruby scripts with "bundle exec" (but only when appropriate).
# http://effectif.com/ruby/automating-bundle-exec
# Github: https://github.com/gma/bundler-exec

## Functions

function bundler-installed() {
  which bundle > /dev/null 2>&1
}

function within-bundled-project() {
  local dir=`pwd`
  while [ `dirname $dir` != "/" ]; do
    [ -f "${dir}/Gemfile" ] && return
    dir=`dirname $dir`
  done
  false
}

function run-with-bundler()
{
  if bundler-installed && within-bundled-project; then
    bundle exec $@
  else
    $@
  fi
}

## Main program

BUNDLED_COMMANDS=( cap capify cucumber rackup rails rake rspec ruby sass sass-convert serve spec unicorn unicorn_rails spring)

for CMD in $BUNDLED_COMMANDS; do
  if [[ $CMD != "bundle" && $CMD != "gem" ]]; then
    alias $CMD="run-with-bundler $CMD"
  fi
done
