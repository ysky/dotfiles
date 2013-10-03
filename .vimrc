set nocompatible
filetype off

" vundler
set rtp+=~/.vim/vundle/
call vundle#rc()

" plugins
Bundle 'gmarik/vundle'
Bundle "Align"
Bundle "QuickBuf"
Bundle "tpope/vim-rails"
Bundle "tpope/vim-surround"
Bundle "tpope/vim-endwise"
Bundle "Shougo/unite.vim"
Bundle "Shougo/unite-outline"
Bundle "ervandew/supertab"
Bundle "ruby-matchit"
Bundle "slim-template/vim-slim"

set t_Co=256

set tabstop=2
set shiftwidth=2
set expandtab
set autoindent
set nocompatible
set incsearch
syntax on
"filetype plugin indent on
filetype indent on
set backspace=indent,eol,start
set number
"setlocal cursorline
"autocmd WinEnter * setlocal cursorline
"autocmd WinLeave * setlocal nocursorline

set laststatus=2
set statusline=%f%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ENC=%{&fileencoding}]\ [POS=%l,%v][LEN=%L]\ [%p%%]
hi StatusLine term=NONE cterm=NONE ctermfg=white ctermbg=blue

nnoremap j gj
nnoremap k gk

nnoremap <Space><Space> :<C-u>set nohlsearch<Return>
nnoremap / :<C-u>set hlsearch<Return>/
nnoremap ? :<C-u>set hlsearch<Return>?
nnoremap * :<C-u>set hlsearch<Return>*
nnoremap # :<C-u>set hlsearch<Return>#

nnoremap <C-l> <C-W>>
nnoremap <C-h> <C-W><

inoremap <C-a> <Esc>^i
inoremap <C-e> <Esc>$a

" leader(\)をスペースに変換しておく
let mapleader = " "
let g:mapleader = " "

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

"surround.vim
let g:surround_37 = "<% \r %>"  " %で<% %>くくり
let g:surround_61 = "<%= \r %>" " =で<%= %>くくり

"for rspec files
autocmd BufRead *_spec.rb syn keyword rubyRspec describe context shared_examples_for shared_context let
highlight def link rubyRspec Function

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

" unite-outline.vim
noremap <C-u><C-o> :Unite outline<CR>

" srcexpl.vim
let g:SrcExpl_winHeight = 8
let g:SrcExpl_UpdateTags = 1
let g:SrcExpl_updateTagsCmd = "ctags --sort=foldcase -R ."

" tags
set tags+=.tags;
