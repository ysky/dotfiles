" settings for filetype {{{
augroup filetypedetect
  au BufNewFile,BufRead Vagrantfile set filetype=ruby
  au BufNewFile,BufRead *_spec.rb set filetype=ruby.rspec
augroup END
" }}}
