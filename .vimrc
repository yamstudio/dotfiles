execute pathogen#infect()
filetype plugin indent on
syntax on

set shellslash
set number
set sw=2
set tabstop=2
set shiftwidth=2
set expandtab
set iskeyword+=:

" tex
let g:tex_flavor = 'latex'
let g:Tex_CompileRule_pdf = 'xelatex --interaction=nonstopmode --shell-escape $*'
let g:Tex_ViewRule_pdf = 'open -a /Applications/Skim.app'

" line length
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/
