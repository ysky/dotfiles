" vim: foldmethod=marker
" vim: foldcolumn=3
" vim: foldlevel=0

" macではshared/.vimrcでdefault offになっているので修正
set modelines=1

if &compatible
  set nocompatible
endif

if v:version >= 704
" settings for dein {{{
  let s:dein_runtimepath = expand("~/.vim/dein/repos/github.com/Shougo/dein.vim")
  execute 'set runtimepath^=' . fnamemodify(s:dein_runtimepath, ':p')

  call dein#begin(expand('~/.vim/dein'))

  " Add or remove your plugins here:
  call dein#load_toml(expand("~/.vim/dein.toml"),      {"lazy": 0})
  call dein#load_toml(expand("~/.vim/dein_lazy.toml"), {"lazy": 1})

  " You can specify revision/branch/tag.
  call dein#add('Shougo/vimshell', { 'rev': '3787e5' })
  call dein#end()
  filetype plugin indent on

  " If you want to install not installed plugins on startup.
  if dein#check_install()
    call dein#install()
  endif
" }}}
else
" settings for neobundle "{{{
  set runtimepath+=~/.vim/bundle/neobundle.vim
  call neobundle#begin(expand('~/.vim/bundle/'))

  " plugins
  NeoBundle 'Shougo/neobundle.vim'
  NeoBundle 'Shougo/unite.vim'
  NeoBundle 'Shougo/neomru.vim'
  NeoBundle 'Shougo/neocomplcache.vim'
  NeoBundle 'Shougo/unite-outline'
  NeoBundle 'Align'
  NeoBundle "vim-ruby/vim-ruby"
  NeoBundle 'tpope/vim-rails'
  NeoBundle 'tpope/vim-surround'
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
  NeoBundle 'tomtom/tcomment_vim'
  NeoBundle 'nathanaelkane/vim-indent-guides'
  NeoBundle "tpope/vim-endwise"
  NeoBundle "jiangmiao/auto-pairs"
  NeoBundle "pangloss/vim-javascript"
  NeoBundle "derekwyatt/vim-scala"
  NeoBundle "mxw/vim-jsx"
  NeoBundle "othree/yajs.vim"
  NeoBundle "Shougo/vimproc", {
  \ 'build' : {
  \   'mac' : 'make -f make_mac.mak',
  \   'unix' : 'make -f make_unix.mak',
  \ },
  \ }

  call neobundle#end()
  filetype plugin indent on
  NeoBundleCheck
" }}}
endif
" settings for base {{{
" ----------------------------------------------
"  基本設定
" ----------------------------------------------
set t_Co=256
set autoread                    " 他で変更があったら自動で読み込み
set ai                          " auto indent
set shiftwidth=2                " インデント幅は2
set tabstop=2                   " tabの幅は2
set expandtab                   " tabをホワイトスペースにする
set number                      " 行数を表示
set backspace=indent,eol,start  " バックスペースですべて消せるようにする
set formatoptions=lmoq          " テキスト整形オプション，マルチバイト系を追加
set vb t_vb=                    " ビープを鳴らさない
set nobackup                    " バックアップファイルを作らない
set incsearch                   " インクリメント検索
set clipboard+=unnamed          " OSのクリップボードを使用する
set pastetoggle=<F10>           " pastemodeのtoggleをF10にわりあて
set wildmenu wildmode=list:full " vimからファイルを開く時にリスト表示
syntax on                       " syntax ハイライトをon

" 分割時は右か下に出す．
set splitright
set splitbelow

" 不可視文字の可視化
set lcs=tab:>-,trail:_,extends:\
set list
highlight SpecialKey cterm=NONE ctermfg=235 ctermbg=0
highlight JpSpace cterm=underline ctermfg=1 ctermbg=0
au BufRead,BufNew * match JpSpace /　/

" vim7.4のsegv対策
if v:version >= 704
  set regexpengine=1
endif

" カーソルの変更
if $TERMCAP =~ "screen"
  let &t_SI .= "\eP\e]50;CursorShape=1\x7\e\\"
  let &t_EI .= "\eP\e]50;CursorShape=0\x7\e\\"
elseif &term =~ "xterm"
  let &t_SI .= "\e]50;CursorShape=1\x7"
  let &t_EI .= "\e]50;CursorShape=0\x7"
endif

" 通常モードに戻った時にすぐにカーソルが戻るように
set timeout
set timeoutlen=1000
set ttimeoutlen=10

" C-fでスクロールしきったときに一行になる挙動を修正
" refs: http://itchyny.hatenablog.com/entry/2016/02/02/210000
noremap <expr> <C-f> max([winheight(0) - 2, 1]) . "\<C-d>" . (line('.') > line('$') - winheight(0) ? 'L' : 'H')

" }}}
" settings for folding {{{
set foldenable
autocmd FileType ruby :set foldmethod=indent
autocmd FileType ruby :set foldlevel=1
autocmd FileType ruby :set foldnestmax=2

autocmd InsertEnter * if !exists("w:last_fdm")
       \| let w:last_fdm=&foldmethod
       \| setlocal foldmethod=manual
       \| endif

autocmd InsertLeave,WinLeave * if exists("w:last_fdm")
       \| let &l:foldmethod=w:last_fdm
       \| unlet w:last_fdm
       \| endif

autocmd FileType ruby normal zR
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
" settings for switch.vim {{{
let g:switch_custom_definitions =
\ [
\   ['if', 'unless'],
\   ['while', 'until'],
\   ['.blank?', '.present?'],
\   ['include', 'extend'],
\   ['class', 'module'],
\   ['.inject', '.delete_if'],
\   ['.map', '.map!'],
\   ['attr_accessor', 'attr_reader', 'attr_writer'],
\   ['=', '<', '<=', '>', '>=', '~>'],
\   ['yes?', 'no?'],
\   [100, ':continue', ':information'],
\   [101, ':switching_protocols'],
\   [102, ':processing'],
\   [200, ':ok', ':success'],
\   [201, ':created'],
\   [202, ':accepted'],
\   [203, ':non_authoritative_information'],
\   [204, ':no_content'],
\   [205, ':reset_content'],
\   [206, ':partial_content'],
\   [207, ':multi_status'],
\   [208, ':already_reported'],
\   [226, ':im_used'],
\   [300, ':multiple_choices'],
\   [301, ':moved_permanently'],
\   [302, ':found'],
\   [303, ':see_other'],
\   [304, ':not_modified'],
\   [305, ':use_proxy'],
\   [306, ':reserved'],
\   [307, ':temporary_redirect'],
\   [308, ':permanent_redirect'],
\   [400, ':bad_request'],
\   [401, ':unauthorized'],
\   [402, ':payment_required'],
\   [403, ':forbidden'],
\   [404, ':not_found'],
\   [405, ':method_not_allowed'],
\   [406, ':not_acceptable'],
\   [407, ':proxy_authentication_required'],
\   [408, ':request_timeout'],
\   [409, ':conflict'],
\   [410, ':gone'],
\   [411, ':length_required'],
\   [412, ':precondition_failed'],
\   [413, ':request_entity_too_large'],
\   [414, ':request_uri_too_long'],
\   [415, ':unsupported_media_type'],
\   [416, ':requested_range_not_satisfiable'],
\   [417, ':expectation_failed'],
\   [422, ':unprocessable_entity'],
\   [423, ':precondition_required'],
\   [424, ':too_many_requests'],
\   [426, ':request_header_fields_too_large'],
\   [500, ':internal_server_error'],
\   [501, ':not_implemented'],
\   [502, ':bad_gateway'],
\   [503, ':service_unavailable'],
\   [504, ':gateway_timeout'],
\   [505, ':http_version_not_supported'],
\   [506, ':variant_also_negotiates'],
\   [507, ':insufficient_storage'],
\   [508, ':loop_detected'],
\   [510, ':not_extended'],
\   [511, ':network_authentication_required'],
\   ['describe', 'context', 'specific', 'example'],
\   ['before', 'after'],
\   ['be_true', 'be_false'],
\   ['get', 'post', 'put', 'delete'],
\   ['==', 'eql', 'equal'],
\   ['\.to_not', '\.to'],
\   { '\([^. ]\+\)\.should\(_not\|\)': 'expect(\1)\.to\2' },
\   { 'expect(\([^. ]\+\))\.to\(_not\|\)': '\1.should\2' }
\ ]
" }}}
" settings for vim-indent-guides {{{
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=234
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=235
" }}}
" settings for vim-markdown {{{
let g:vim_markdown_folding_disabled=1
" }}}
" settings for neocomplcache {{{
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 2
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : ''
    \ }

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplcache#smart_close_popup() . "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplcache#close_popup()
inoremap <expr><C-e>  neocomplcache#cancel_popup()

"if !exists('g:neocomplcache_force_omni_patterns')
"  let g:neocomplcache_force_omni_patterns = {}
"endif
"let g:neocomplcache_force_omni_patterns.ruby = '[^.*\t]\.\w*\|\h\w*::'
"" }}}
" settings for supertab {{{
let g:SuperTabDefaultCompletionType = "<c-n>"
" }}}
" settings for cursorline {{{
augroup vimrc-auto-cursorline
  autocmd!
  autocmd CursorMoved,CursorMovedI * call s:auto_cursorline('CursorMoved')
  autocmd CursorHold,CursorHoldI * call s:auto_cursorline('CursorHold')
  autocmd WinEnter * call s:auto_cursorline('WinEnter')
  autocmd WinLeave * call s:auto_cursorline('WinLeave')

  let s:cursorline_lock = 0
  function! s:auto_cursorline(event)
    if a:event ==# 'WinEnter'
      setlocal cursorline
      let s:cursorline_lock = 2
    elseif a:event ==# 'WinLeave'
      setlocal nocursorline
    elseif a:event ==# 'CursorMoved'
      if s:cursorline_lock
        if 1 < s:cursorline_lock
          let s:cursorline_lock = 1
        else
          setlocal nocursorline
          let s:cursorline_lock = 0
        endif
      endif
    elseif a:event ==# 'CursorHold'
      setlocal cursorline
      let s:cursorline_lock = 1
    endif
  endfunction
augroup END
" }}}
" settings for auto-pairs {{{
let g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`', '|':'|'}
" }}}
" settings for filetype {{{
au BufNewFile,BufRead *.es6 setf javascript
au BufNewFile,BufRead Vagrantfile set filetype=ruby
" }}}
