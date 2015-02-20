" vim: foldmethod=marker
" vim: foldcolumn=3
" vim: foldlevel=0

" settings for neobundle "{{{
set runtimepath+=~/.vim/bundle/neobundle.vim
call neobundle#begin(expand('~/.vim/bundle/'))

" plugins
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'Shougo/unite-outline'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Align'
NeoBundle 'tpope/vim-rails'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'ervandew/supertab'
NeoBundle 'ruby-matchit'
NeoBundle 'slim-template/vim-slim'
NeoBundle 'plasticboy/vim-markdown'
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'rodjek/vim-puppet'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'soramugi/auto-ctags.vim'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'AndrewRadev/switch.vim'

call neobundle#end()
filetype plugin indent on
NeoBundleCheck
" }}}
" settings for base {{{
" ----------------------------------------------
"  基本設定
" ----------------------------------------------
set t_Co=256
set autoread                   " 他で変更があったら自動で読み込み
set ai                         " auto indent
set shiftwidth=2               " インデント幅は2
set tabstop=2
set expandtab                  " tabをホワイトスペースにする
set number                     " 行数を表示
set backspace=indent,eol,start " バックスペースですべて消せるようにする
set formatoptions=lmoq         " テキスト整形オプション，マルチバイト系を追加
set vb t_vb=                   " ビープを鳴らさない
set nobackup                   " バックアップファイルを作らない
set nocompatible               " 互換もモードを禁止
set incsearch
set clipboard+=unnamed         " OSのクリップボードを使用する
syntax on                      " syntax ハイライトをon

" 分割時は右か下に出す．
set splitright
set splitbelow

" 不可視文字の可視化
set lcs=tab:>-,trail:_,extends:\
set list
highlight SpecialKey cterm=NONE ctermfg=235 ctermbg=0
highlight JpSpace cterm=underline ctermfg=1 ctermbg=0
au BufRead,BufNew * match JpSpace /　/
" }}}
" settings for status line {{{
set laststatus=2
"set statusline=%f%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ENC=%{&fileencoding}]\ [POS=%l,%v][LEN=%L]\ [%p%%]
let &statusline = ''
let &statusline .= '%f%m%r%h%w'
let &statusline .= ' [FORMAT=%{&ff}][TYPE=%Y][ENC=%{&fileencoding}]'
let &statusline .= '%{&bomb ? "[BOM]" : ""}'
let &statusline .= ' [POS=%l,%v][LEN=%L][%p%%]'

hi StatusLine term=NONE cterm=NONE ctermfg=white ctermbg=blue
" }}}
" settings for mac os x {{{
" iTerm2でモードによってカーソルを変更
if has("mac")
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
  set ambiwidth=double
endif
" }}}
" settings for keymap {{{
" 挿入モードでCtrl+kでクリップボードの内容を貼り付けられるように
imap <C-K> <ESC>"*pa

nnoremap j gj
nnoremap k gk

nnoremap <Space><Space> :<C-u>set nohlsearch<Return>
nnoremap / :<C-u>set hlsearch<Return>/
nnoremap ? :<C-u>set hlsearch<Return>?
nnoremap * :<C-u>set hlsearch<Return>*
nnoremap # :<C-u>set hlsearch<Return>#

nnoremap <C-l> <C-W>>
nnoremap <C-h> <C-W><

" window移動のショートカット
nnoremap sh <C-w>h
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sw <C-w>w

inoremap <C-a> <Esc>^i
inoremap <C-e> <Esc>$a

" leader(\)をスペースに変換しておく
let mapleader = " "
let g:mapleader = " "
" }}}
" settings for colorscheme {{{
colorscheme hybrid
highlight Normal ctermbg=none
highlight Pmenu ctermbg=4
highlight PmenuSel ctermbg=1
highlight PMenuSbar ctermbg=4
highlight Visual ctermbg=240
highlight Search ctermbg=100
" }}}
" settings for surround.vim {{{
" let g:surround_37 = "<% \r %>"  " %で<% %>くくり
" let g:surround_61 = "<%= \r %>" " =で<%= %>くくり
let g:surround_{char2nr("%")} = "<% \r %>"
let g:surround_{char2nr("=")} = "<%= \r %>"
let g:surround_{char2nr("!")} = "<!-- \r -->"
" }}}
" settings for unite.vim {{{
" unite.vim
"let g:unite_enable_split_vertically=1
"noremap <C-u> :Unite -buffer-name=files file buffer file_mru<CR>

" バッファ一覧
nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
" ファイル一覧
nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" レジスタ一覧
nnoremap <silent> ,ur :<C-u>Unite -buffer-name=register register<CR>
" 最近使用したファイル一覧
nnoremap <silent> ,um :<C-u>Unite file_mru<CR>
" 常用セット
nnoremap <silent> ,uu :<C-u>Unite buffer file_mru<CR>
" 全部乗せ
nnoremap <silent> ,ua :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>

" unite-outline.vim
noremap <C-u><C-o> :Unite outline<CR>

" ウィンドウを分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
" ウィンドウを縦に分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
au FileType unite inoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
" ESCキーを2回押すと終了する
au FileType unite nnoremap <silent> <buffer> <ESC><ESC> q
au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>q
" }}}
" settings for binary (vim -b) {{{
augroup BinaryXXD
  autocmd!
  autocmd BufReadPre  *.bin let &binary =1
  autocmd BufReadPost * if &binary | silent %!xxd -g 1
  autocmd BufReadPost * set ft=xxd | endif
  autocmd BufWritePre * if &binary | %!xxd -r | endif
  autocmd BufWritePost * if &binary | silent %!xxd -g 1
  autocmd BufWritePost * set nomod | endif
augroup END
" }}}
" settings for auto-ctags {{{
set tags+=$HOME/.tags
set tags+=.git/tags
set tags+=.svn/tags
let g:auto_ctags = 1
let g:auto_ctags_directory_list = ['.git', '.svn']
let g:auto_ctags_tags_name = 'tags'
" }}}
" settings for lightline {{{
let g:lightline = {
        \ 'mode_map': {'c': 'NORMAL'},
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
        \ },
        \ 'component_function': {
        \   'modified': 'MyModified',
        \   'readonly': 'MyReadonly',
        \   'fugitive': 'MyFugitive',
        \   'filename': 'MyFilename',
        \   'fileformat': 'MyFileformat',
        \   'filetype': 'MyFiletype',
        \   'fileencoding': 'MyFileencoding',
        \   'mode': 'MyMode'
        \ }
        \ }

function! MyModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
endfunction

function! MyFilename()
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  try
    if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
      return fugitive#head()
    endif
  catch
  endtry
  return ''
endfunction

function! MyFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  return winwidth(0) > 60 ? lightline#mode() : ''
endfunction
" }}}
" settings for neocomplcache {{{
" Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Enable heavy features.
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
      \ 'default' : '',
      \ 'vimshell' : $HOME.'/.vimshell_hist',
      \ 'scheme' : $HOME.'/.gosh_completions'
      \ }

" AutoComplPop like behavior.
let g:neocomplcache_enable_auto_select = 1
" }}}
