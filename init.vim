call plug#begin('~/.local/share/nvim/plugged')

function! BuildYCM(info)
    " info is a dictionary with 3 fields
    " - name:   name of the plugin
    " - status: 'installed', 'updated', or 'unchanged'
    " - force:  set on PlugInstall! or PlugUpdate!
    if a:info.status == 'installed' || a:info.force
        !./install.py --clang-completer
    endif
endfunction

Plug 'Chiel92/vim-autoformat'
Plug 'bkad/CamelCaseMotion'
Plug 'fatih/vim-go'
Plug 'flazz/vim-colorschemes'
Plug 'jlanzarotta/bufexplorer'
Plug 'majutsushi/tagbar'
Plug 'pboettch/vim-cmake-syntax'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'valloric/YouCompleteMe', { 'do': function('BuildYCM') }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-python/python-syntax'
Plug 'w0rp/ale'

call plug#end()

" Plugin config.
let g:deoplete#enable_at_startup = 1

let g:ale_open_list = 1
let g:ale_completion_enabled = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1

let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_info_str = 'I'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%|%severity%] %s% (code)%'

" This defaults to *, which causes all checks to be run regardless of what the
" .clang-tidy file says. Setting this to an empty list uses the file instead.
let g:ale_cpp_clangtidy_checks = []

" By default C++ is also linted with clangcheck, which is redundant.
let g:ale_linters = {
\   'cpp': ['clang', 'clangtidy'],
\   'java': [],
\   'python': ['pylint'],
\}

let g:ycm_filetype_blacklist = { 'java': 1 }

let g:formatdef_yapf = "'yapf -l '.a:firstline.'-'.a:lastline"
let g:formatters_python = ['yapf']

" UI options.
colorscheme zenburn
let g:airline_theme='zenburn'

" Enable mouse handling in all modes.
set mouse=a

" Even NERDTree.
let g:NERDTreeMouseMode = 2

" Right click opens a pop up menu for the item under the mouse cursor.
set mousemodel=popup_setpos

set list " Show unwanted whitespace characters.
set cursorline " Highlight current line.
set number " Show line numbers.

set colorcolumn=+1 " Highlight the column limit.
highlight ColorColumn ctermbg=238
highlight ColorColumn guibg=#444444

" Show a pop up menu for insert mode tab complete, even if there is only one
" option, autocomplete to the longest matching substring, and show extra
" information about the currently selected match.
set completeopt=menu,menuone,longest,preview

" Make tab completion similar to bash.
set wildmode=list:longest

" Use ctrl-n and ctrl-p to scroll through matches.
set wildmenu

" Ignore list for tab completion.
set wildignore=*.o,*.obj,*~

" Limit tab completion popup menu height
set pumheight=15

" Vertical/horizontal scroll off settings.
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

set laststatus=2

" Complete options (disable preview scratch window)
set completeopt=menu,menuone,longest

" Key mappings.
nnoremap Y y$
inoremap jj <ESC>
tnoremap <Esc> <C-\><C-n>
map <C-K> :Autoformat<CR>
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"

" Explorer mappings.
nnoremap <f1> :BufExplorer<cr>
nnoremap <f2> :NERDTreeToggle<cr>
nnoremap <f3> :TagbarToggle<cr>

set pastetoggle=<f2>

" Q wraps the selection to fit the column limit.
noremap Q gq

" CamelCase motion should be the default. Note that the uppercase variants of
" these motions (e.g. cW) will still behave normally.
map w <Plug>CamelCaseMotion_w
map b <Plug>CamelCaseMotion_b
map e <Plug>CamelCaseMotion_e
sunmap w
sunmap b
sunmap e

" Don't continue comments when pushing o/O.
set formatoptions-=o

" This changes the default behavior of cw from:
"
" foo_bar -> foo_bar
" ^              ^
"
" to:
"
" foo_bar -> foo_bar
" ^             ^
"
" Note that dw is left untouched.
nmap cw ce

" Make <c-l> clear the highlight as well as redraw.
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

" Default formatting options.
set textwidth=80

" Make it easier to change indentation types and sizes.
function! UseSpaces()
    setlocal listchars=tab:»\ ,trail:⋅,nbsp:⋅
    setlocal expandtab
endfunction
command! UseSpaces call UseSpaces()

function! UseTabs()
    setlocal listchars=tab:\ \ ,trail:⋅,nbsp:⋅
    setlocal noexpandtab
endfunction
command! UseTabs call UseTabs()
function! IndentSize(size)
    exec "setlocal tabstop=" . a:size
    exec "setlocal shiftwidth=" . a:size
endfunction
command! Use2 call IndentSize(2)
command! Use4 call IndentSize(4)
command! Use8 call IndentSize(8)

" Doesn't use the functions above since we want set rather than setlocal.
set tabstop=4
set shiftwidth=4
set expandtab
set listchars=tab:»\ ,trail:⋅,nbsp:⋅

" Mechanical pieces.

" Undo/backup files settings
if has("win32")
    set undodir=~/vimfiles/undofiles
    set directory=~/vimfiles/backup//
else
    set undodir=~/.vim/undofiles
    set directory=~/.vim/backup//
endif

set undofile

" Hide buffers when not displayed.
set hidden

set autochdir

" Jump to last cursor position when opening a file.
" Don't do it when writing a commit log entry.
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'svn\|commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

" Spell check in commit messages.
autocmd filetype svn,*commit* setlocal spell
autocmd filetype svn,*commit* setlocal tw=70
