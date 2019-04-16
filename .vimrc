filetype plugin indent on
syntax on

set shellslash
set number
set sw=2
set tabstop=2
set shiftwidth=2
set expandtab
set iskeyword+=:

" line length
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/
