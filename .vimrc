let g:dotvim_settings = {}
let g:dotvim_settings.version = 1
let g:dotvim_settings.default_indent = 4
" ycm does not work
let g:dotvim_settings.autocomplete_method='ycm'
let g:dotvim_settings.enable_cursorcolumn = 1
let g:dotvim_settings.plugin_groups_include = ['python', 'javascript', 'web', 'clojure']
" the theme
let g:dotvim_settings.colorscheme = 'molokai'
let g:molokai_original = 1
let g:quickhl_manual_enable_at_startup=1

" this setting is for fugitive browse
"XXX remove this if you quit the company :)
let g:fugitive_github_domains = ['https://github.wgenhq.net']

" special case for vim without plugins
if exists('g:plugins')
  set showtabline=0
  set statusline=0
  let g:dotvim_settings.plugin_groups = ['editing']
  " let g:dotvim_settings.plugin_groups_include = []
endif

source ~/.vim/vimrc
" for solarized colorscheme
set background=dark

" for some python magic
augroup pyrun
  au!
  au FileType python nnoremap <leader>r :!python %<cr>
augroup END
" other kinds of customizations go here
if has('gui_running')
  set guifont=menlo\ for\ powerline:h18
  highlight TagbarHighlight guibg=DarkGreen guifg=White
endif
set nowrap
" highlight Pmenu guibg=DarkGreen guifg=White
if g:dotvim_settings.colorscheme ==# 'molokai'
  highlight Search guibg=#3E4D36 guifg=White
endif
