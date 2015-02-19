" neobundle
set runtimepath+=~/.vim/bundle/neobundle.vim
call neobundle#begin(expand('~/.vim/bundle/'))

" plugins
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/unite-outline'
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

call neobundle#end()

filetype plugin indent on

NeoBundleCheck

set t_Co=256

" ----------------------------------------------
"  基本設定
" ----------------------------------------------
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
set nocompatible " 互換もモードを禁止
set incsearch
syntax on " syntax ハイライトをon
" filetype on
" " filetype indent plugin on
" filetype indent on

"setlocal cursorline
"autocmd WinEnter * setlocal cursorline
"autocmd WinLeave * setlocal nocursorline

set laststatus=2
"set statusline=%f%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ENC=%{&fileencoding}]\ [POS=%l,%v][LEN=%L]\ [%p%%]
let &statusline = ''
let &statusline .= '%f%m%r%h%w'
let &statusline .= ' [FORMAT=%{&ff}][TYPE=%Y][ENC=%{&fileencoding}]'
let &statusline .= '%{&bomb ? "[BOM]" : ""}'
let &statusline .= ' [POS=%l,%v][LEN=%L][%p%%]'

hi StatusLine term=NONE cterm=NONE ctermfg=white ctermbg=blue

" OSのクリップボードを使用する
set clipboard+=unnamed

" for mac os x
" iTerm2でモードによってカーソルを変更
if has("mac")
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
  set ambiwidth=double
endif

" ノーマルモードに戻った時にすぐにカーソルが変化するように
"inoremap <Esc> <Esc>gg`]

" 挿入モードでCtrl+kでクリップボードの内容を貼り付けられるように
imap <C-K> <ESC>"*pa

" Ev/Rvでvimrcを編集/再読込できるように
command! Ev edit $MYVIMRC
command! Rv source $MYVIMRC

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

" colorscheme
colorscheme hybrid
highlight Normal ctermbg=none
highlight Pmenu ctermbg=4
highlight PmenuSel ctermbg=1
highlight PMenuSbar ctermbg=4
highlight Visual ctermbg=240
highlight Search ctermbg=100

" 分割時は右か下に出す．
set splitright
set splitbelow

"vba形式のプラグインをインストールするときは
":let g:vimball_home = "~/.vim/bundle/Align"
":source %
"でインストールパスを変更して対応

" surround.vimのrailsカスタム
" let g:surround_37 = "<% \r %>"  " %で<% %>くくり
" let g:surround_61 = "<%= \r %>" " =で<%= %>くくり
let g:surround_{char2nr("%")} = "<% \r %>"
let g:surround_{char2nr("=")} = "<%= \r %>"
let g:surround_{char2nr("!")} = "<!-- \r -->"

"for rspec files
" autocmd BufRead *_spec.rb syn keyword rubyRspec describe context shared_examples_for shared_context let
" highlight def link rubyRspec Function

" qfixapp.vim
set runtimepath+=~/.vim/bundle/qfixapp.vim
" キーマップリーダー
let QFixHowm_Key = 'g'
" howm_dirはファイルを保存したいディレクトリを設定
let howm_dir             = '~/.howm'
let howm_filename        = '%Y/%m/%Y-%m-%d-%H%M%S.txt'
let howm_fileencoding    = 'utf-8'
let howm_fileformat      = 'unix'

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

" srcexpl.vim
let g:SrcExpl_winHeight = 8
let g:SrcExpl_UpdateTags = 1
let g:SrcExpl_updateTagsCmd = "ctags --sort=foldcase -R ."

" tags
set tags+=.tags;

" vim -b
augroup BinaryXXD
  autocmd!
  autocmd BufReadPre  *.bin let &binary =1
  autocmd BufReadPost * if &binary | silent %!xxd -g 1
  autocmd BufReadPost * set ft=xxd | endif
  autocmd BufWritePre * if &binary | %!xxd -r | endif
  autocmd BufWritePost * if &binary | silent %!xxd -g 1
  autocmd BufWritePost * set nomod | endif
augroup END

" 不可視文字の可視化
set lcs=tab:>-,trail:_,extends:\
set list
highlight SpecialKey cterm=NONE ctermfg=235 ctermbg=0
highlight JpSpace cterm=underline ctermfg=1 ctermbg=0
au BufRead,BufNew * match JpSpace /　/

" lightline
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
