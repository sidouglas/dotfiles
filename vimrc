" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" Set shift width to 4 spaces.
set shiftwidth=2

" When scrolling, keep the cursor 5 lines below the top and 5 lines above the bottom of the screen
set scrolloff=5

" Set tab width to 4 columns.
set tabstop=2

" Use space characters instead of tabs.
set expandtab

" Do not save backup files.
set nobackup

" Do not let cursor scroll below or above N number of lines when scrolling.
set scrolloff=10

" Do not wrap lines. Allow long lines to extend as far as the line goes.
set nowrap

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Ignore capital letters during search.
set ignorecase

" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
set smartcase

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Set the commands to save in history default number is 20.
set history=1000

" Enable hybrid line numbers (absolute for current line, relative for others)
set number relativenumber

" Enable hybrid line numbers (absolute for current line, relative for others)
set nu rnu

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

set clipboard=unnamed          " ┐
                               " │ Use the system clipboard
if has("unnamedplus")          " │ as the default register
    set clipboard+=unnamedplus " │
endif                          " ┘


" PLUGINS ---------------------------------------------------------------- {{{
call plug#begin('~/.vim/plugged')
" Plugin code goes here.
Plug 'dense-analysis/ale'
Plug 'preservim/nerdtree'
Plug 'easymotion/vim-easymotion'
Plug 'justinmk/vim-sneak'
" }}}


" MAPPINGS --------------------------------------------------------------- {{{

" Mappings code goes here.
" Set the backslash as the leader key.
let mapleader = " "
" Type jj to exit insert mode quickly.
inoremap jj <Esc>

" Press b to jump back to the last cursor position.
nnoremap <leader>b ``
" These move lines up and down using ctrl J/K (compatible with idea)
nnoremap K :m .-2<CR>==
nnoremap J :m .+1<CR>==
vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv
"adding a new line below the current line without moving your cursor to that new l
"ine
nnoremap <CR> a<CR><Esc>k$

" }}}
"Now Shift-h (capital H) and Shift-l (capital L) will switch you quickly between tabs
nnoremap H gT
nnoremap L gt

" VIMSCRIPT -------------------------------------------------------------- {{{

" This will enable code folding.
" Use the marker method of folding.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" More Vimscripts code goes here.

" }}}


" STATUS LINE ------------------------------------------------------------ {{{

" Status bar code goes here.

" }}}

" Text expansions ------------------------------------------------------------
inoremap ;cl console.log();<Left><Left>
nnoremap <leader>cl oconsole.log();<Left><Left>
nnoremap <leader>r :source $MYVIMRC<CR>
