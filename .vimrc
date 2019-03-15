"Turn on syntax highlighting
syntax enable
set background=dark
colorscheme slate
filetype plugin indent on

"Don't wrap lines
set nowrap

"Show line numbers 
set number

"Use 2 spaces per tab
set tabstop=2
set shiftwidth=2  
set softtabstop=2
set smarttab
set expandtab
set fileformats+=dos

"Newlines should auto indent
set autoindent

"Ignore case when searching except when using a capital letter
set ignorecase
set smartcase

"old: colorscheme darkblue

"Highlight trailing whitespace
"autocmd WinEnter * highlight ExtraWhitespace ctermbg=red guibg=red
"autocmd WinEnter * match ExtraWhitespace /\s\+$/
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
"
"Invisible character colors 
highlight NonText guifg=#8A6060
highlight SpecialKey guifg=#8A6060


"Highlight searched terms
set hlsearch
"Highlight found first search term as you type the search
set incsearch

"Store a lot of history and undo
set history=1000
set undolevels=1000

"Get rid of temp and swap files
set nobackup
set noswapfile

"Show line number
set ruler

set foldmethod=indent
au FileType javascript call JavaScriptFold()
au BufRead,BufNewFile *.jsm set filetype=javascript

"Showthe fold in the left where the line numbers are
set foldcolumn=3
"Map spacebar to fold/unfold
nnoremap <Space> za
map <a> MACROTEXT

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬
set list!

" let g:syntastic_jsx_checkers = ['jsxhint']
let g:syntastic_javascript_checkers = ['standard']

" copy and paste
vmap <C-c> "+yi
vmap <C-x> "+c
vmap <C-v> c<ESC>"+p
imap <C-v> <ESC>"+pa


let @l='iconsole.log("--------------------1");'

" To install this:
" mkdir -p ~/.vim/autoload ~/.vim/bundle && \
" curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
execute pathogen#infect()
syntax on

autocmd FileType go setlocal ts=2 sts=2 sw=2 noexpandtab
