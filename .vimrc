" Lots of this taken from http://vim.wikia.com/wiki/Example_vimrc on 2018/1/17

" Sanely reset options when re-sourcing .vimrc
set nocompatible
"filetype off

"" Setting up vundle
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()
"Plugin 'VundleVim/Vundle.vim'
"
"Plugin 'wincent/command-t'
"Plugin 'terryma/vim-multiple-cursors'
"
"call vundle#end()

" Attempt to determine the type of a file based on name
filetype indent plugin on

" Softtabs in vim
set tabstop=4 softtabstop=0 expandtab shiftwidth=4

" When splitting, put cursor in right window
set splitright
set splitbelow

" Syntax highlighting
syntax on

" Set color column
highlight ColorColumn ctermbg=6

" Put a vertical bar at 80 characters
if exists('+colorcolumn')
    set colorcolumn=81
else
    au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

" Highlight searches
set hlsearch

" Never put things at the top or bottom of the screen
set scrolloff=25

" Case insensitive searching except when using caps
set ignorecase smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" Keep same indentation as previous line by default
set autoindent

" Shortcut to comment in C/C++
map <c-n> :s:^\(\s*\):\1\/\/ <CR>:noh<CR>
map <c-m> :s:^\(\s*\)\/\/ :\1<CR>:noh<CR>

" Use dialog to confirm unsaved changes instead of failing a command
set confirm

" Remap deletes and copies away from default register
nnoremap d "_d
vnoremap d "_d
nnoremap D "_D
vnoremap D "_D
nnoremap c "_c
vnoremap c "_c
nnoremap C "_C
vnoremap C "_C

" Always cut copy and paste to global buffer
nnoremap x "+x
vnoremap x "+x
nnoremap y "+y
vnoremap y "+y
nnoremap p "+p
vnoremap p "+p
nnoremap P "+P
vnoremap P "+P

" Make it easier to find which pane is active
nnoremap F <Esc>ggVG
vnoremap F <Esc>ggVG

" Shift x removes pair of parentheses
nnoremap X %x``x
vnoremap X %x``x

" Control shift X removes pair of braces and everything between
nnoremap <c-X> d%
vnoremap <c-X> d%

" For reloading everything
map <Leader>e :bufdo e<CR>

" Use this to disable highlighting
nnoremap <c-_> :noh<CR>

" Use ctrl-^ for caps lock to avoid mess when in normal mode with caps
for c in range(char2nr('A'), char2nr('Z'))
    execute 'lnoremap ' . nr2char(c+32) . ' ' . nr2char (c)
    execute 'lnoremap ' . nr2char(c) . ' ' . nr2char(c+32)
endfor
autocmd InsertLeave * set iminsert=0

" Flash instead of beep
set visualbell
set t_vb=

" Enable use of mouse for all modes
set mouse=a

" Set command window to height of 2
set cmdheight=2

" Show line numbers
set number relativenumber

" Quickly time out on keycodes, but never on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>

" Use <F3> to toggle between highlight and no highlight
nnoremap <F3> :set hlsearch!<CR>

" Save as control s
noremap <c-s> :source ~/.vimrc<CR>

" Remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" Highlight current line
if exists('+colorcolumn')
    function! s:DimInactiveWindows()
        for i in range(1, tabpagewinnr(tabpagenr(), '$'))
            let l:range = ""
            if i != winnr()
                if &wrap
                    let l:width=256 " max
                else
                    let l:width=winwidth(i)
                endif
                let l:range = join(range(1, l:width), ',')
            endif
            " This line is what makes inactive windows a different color
            call setwinvar(i, '&colorcolumn', l:range)
        endfor
        if exists('+colorcolumn')
            set colorcolumn=80
        else
            au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
        endif
    endfunction
    augroup DimInactiveWindows
        au!
        "au WinEnter * call s:DimInactiveWindows()
        au WinEnter * set cursorline
        au WinLeave * set nocursorline
    augroup END
endif

" Don't wrap lines
set nowrap

""""""""""""" PLUGINS """"""""""""""

" Plugin to use fuzzy searching
"set runtimepath^=~/.vim/bundle/ctrlp-cmatcher.vim
"let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }
set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_custom_ignore = {
    \ 'dir': '\v[\/](\.svn|objs|bin)$',
    \ 'file': '\v\.(swp,zip,tar,gz,o,d,dbo,dnm,dla,dep)$',
    \ }
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_switch_buffer = 'et'
set wildignore+=*/tmp*,*.so,*.swp,*.zip,*.orig,*.dep,*.dla,*.dnm,*.o,*.d,*.dbo
let g:ctrlp_user_command = 'find %s -type f'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_root_markers = [ '.svn' ]
"set runtimepath^=~/.vim/bundle/command-t.vim
"let g:CommandTMaxFiles=20000

" Multiple cursor stuff
" set runtimepath^=~/.vim/bundle/vim-multiple-cursors.vim
" let g:multi_cursor_next_key = '<c-d>'
" let g:multi_cursor_prev_key = '<c-b>'
" let g:multi_cursor_skip_key = '<c-x>'
" let g:multi_cursor_quit_key = '<Esc>'
" let g:multi_cursor_start_key = '<c-d>'
" let g:multi_cursor_start_word_key = '<c-d>'

" Plugin to surround with braces when highlighted
set runtimepath^=~/.vim/bundle/vim-surround.vim

" Plugin to switch between header and source
set runtimepath^=~/.vim/bundle/CurtineIncSw.vim
map <F5> :call CurtineIncSw()<CR>

