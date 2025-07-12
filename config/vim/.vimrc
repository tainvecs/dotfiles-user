" ------------------------------------------------------------------------------
" Vim Directory
" ------------------------------------------------------------------------------


let g:netrw_home = $VIM_STATE_HOME


" ------------------------------------------------------------------------------
" Basic Setup
" ------------------------------------------------------------------------------


" Encoding
scriptencoding utf-8
set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8

" Tabs
set expandtab                       " Use spaces instead of tabs
set smarttab                        " Enable smart-tabs
set shiftwidth=4                    " Number of auto-indent spaces
set softtabstop=4                   " Number of spaces per Tab
set tabstop=4

" Line Number
set number relativenumber           " Enable both absolute and relative numbers

" Searching
set incsearch                       " Searches for strings incrementally
set hlsearch                        " Highlight all search results
set smartcase                       " Enable smart-case search
set ignorecase                      " Always case-insensitive

" Ident
"set autoindent                     " Auto-indent new lines
set smartindent                     " Enable smart-indent

" Wrap
set textwidth=100                   " Line wrap (number of cols)
set linebreak                       " Break lines at word (requires Wrap lines)

" Fold
set foldmethod=syntax
set nofoldenable

" Map leader
let mapleader=','

" Other
set backspace=indent,eol,start      " Fix backspace indent
set undolevels=1000                 " Number of undo levels
set showmatch                       " Highlight matching brace
set visualbell                      " Use visual bell (no beeping)
set ttyfast
set listchars=tab:▸\ ,eol:$


" ------------------------------------------------------------------------------
" visual settings
" ------------------------------------------------------------------------------


syntax on
set ruler                           " Show row and column ruler information
set number                          " Show line numbers
set laststatus=2                    " always show status line

" Color
set t_Co=256
colorscheme desertEx
