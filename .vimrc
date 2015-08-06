set autoindent
set tabstop=4
set shiftwidth=4
set number
set esckeys
syntax on
set expandtab
filetype plugin on
set noro
color monokai

execute pathogen#infect()
let maplocalleader = '\'

"Compile LaTeX and open resultant pdf"
command Latex execute "!pdflatex % && i3-msg 'workspace 5;exec evince -s %:p:r.pdf'"|redraw!
autocmd Filetype tex setlocal smartindent


let g:tex_flavor='latex'                      " Force .tex to mean LaTeX, not plain TeX
let g:Tex_FoldedSections = 'section,subsection,figure,equation,eqnarray'

syntax enable
au BufRead,BufNewFile *.cir set filetype=spice

au BufRead,BufNew *.md set filetype=markdown
