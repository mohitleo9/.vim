let g:dotvim_settings = {}
let g:dotvim_settings.version = 1
" let g:dotvim_settings.default_indent = 4
" ycm does not work
let g:dotvim_settings.autocomplete_method='ycm'
let g:dotvim_settings.enable_cursorcolumn = 1
let g:dotvim_settings.plugin_groups_include = ['python', 'javascript', 'web']
" the theme
let g:dotvim_settings.colorscheme = 'molokai'
let g:molokai_original = 1
let g:quickhl_manual_enable_at_startup=1

" this setting is for fugitive browse
"XXX remove this if you quit the company :)
let g:fugitive_github_domains = ['https://github.wgenhq.net']


source ~/.vim/vimrc
" for solarized colorscheme
set background=dark

" for some python magic
augroup pyrun
  au!
  au FileType python nnoremap <leader>r :!python %<cr>
augroup END
" other kinds of customizations go here
set guifont=menlo\ for\ powerline:h18
set nowrap
" highlight Pmenu guibg=DarkGreen guifg=White
" highlight Search guibg=DarkGreen guifg=white gui=NONE
