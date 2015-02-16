" vim: fdm=marker ts=2 sts=2 sw=2 fdl=9

" detect OS {{{
  let s:is_windows = has('win32') || has('win64')
  let s:is_cygwin = has('win32unix')
  let s:is_macvim = has('gui_macvim')
"}}}

" dotvim settings {{{
  if !exists('g:dotvim_settings') || !exists('g:dotvim_settings.version')
    echom 'The g:dotvim_settings and g:dotvim_settings.version variables must be defined.  Please consult the README.'
    finish
  endif

  if g:dotvim_settings.version != 1
    echom 'The version number in your shim does not match the distribution version.  Please consult the README changelog section.'
    finish
  endif

  " initialize default settings
  let s:settings = {}
  let s:settings.default_indent = 4
  let s:settings.max_column = 120
  let s:settings.autocomplete_method = 'neocomplcache'
  let s:settings.enable_cursorcolumn = 0
  let s:settings.colorscheme = 'jellybeans'
  if has('lua')
    let s:settings.autocomplete_method = 'neocomplete'
  elseif filereadable(expand("~/.vim/bundle/YouCompleteMe/python/ycm_core.*"))
    let s:settings.autocomplete_method = 'ycm'
  endif

  if exists('g:dotvim_settings.plugin_groups')
    let s:settings.plugin_groups = g:dotvim_settings.plugin_groups
  else
    let s:settings.plugin_groups = []
    call add(s:settings.plugin_groups, 'core')
    call add(s:settings.plugin_groups, 'web')
    call add(s:settings.plugin_groups, 'javascript')
    call add(s:settings.plugin_groups, 'ruby')
    call add(s:settings.plugin_groups, 'python')
    call add(s:settings.plugin_groups, 'scala')
    call add(s:settings.plugin_groups, 'clojure')
    call add(s:settings.plugin_groups, 'go')
    call add(s:settings.plugin_groups, 'scm')
    call add(s:settings.plugin_groups, 'editing')
    call add(s:settings.plugin_groups, 'indents')
    call add(s:settings.plugin_groups, 'navigation')
    call add(s:settings.plugin_groups, 'unite')
    call add(s:settings.plugin_groups, 'autocomplete')
    call add(s:settings.plugin_groups, 'textobj')
    call add(s:settings.plugin_groups, 'misc')
    if s:is_windows
      call add(s:settings.plugin_groups, 'windows')
    endif
    " exclude all language-specific plugins by default
    if !exists('g:dotvim_settings.plugin_groups_exclude')
      let g:dotvim_settings.plugin_groups_exclude = ['web','javascript','ruby','python','go','scala']
    endif
    for group in g:dotvim_settings.plugin_groups_exclude
      let i = index(s:settings.plugin_groups, group)
      if i != -1
        call remove(s:settings.plugin_groups, i)
      endif
    endfor

    if exists('g:dotvim_settings.plugin_groups_include')
      for group in g:dotvim_settings.plugin_groups_include
        call add(s:settings.plugin_groups, group)
      endfor
    endif
  endif

  " override defaults with the ones specified in g:dotvim_settings
  for key in keys(s:settings)
    if has_key(g:dotvim_settings, key)
      let s:settings[key] = g:dotvim_settings[key]
    endif
  endfor
"}}}

" setup & neobundle {{{
  set nocompatible
  set all& "reset everything to their defaults
  if s:is_windows
    set rtp+=~/.vim
  endif
  set rtp+=~/.vim/bundle/neobundle.vim
  call neobundle#begin(expand('~/.vim/bundle/'))
  " Let NeoBundle manage NeoBundle
  NeoBundleFetch 'Shougo/neobundle.vim'
"}}}

" functions {{{
  function! Source(begin, end) "{{{
    let lines = getline(a:begin, a:end)
    for line in lines
      execute line
    endfor
  endfunction "}}}
  function! Preserve(command) "{{{
    " preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    execute a:command
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
  endfunction "}}}
  function! StripTrailingWhitespace() "{{{
    call Preserve("%s/\\s\\+$//e")
  endfunction "}}}
  function! EnsureExists(path) "{{{
    if !isdirectory(expand(a:path))
      call mkdir(expand(a:path))
    endif
  endfunction "}}}
  function! CloseWindowOrKillBuffer() "{{{
    let number_of_windows_to_this_buffer = len(filter(range(1, winnr('$')), "winbufnr(v:val) == bufnr('%')"))

    " never bdelete a nerd tree
    if matchstr(expand("%"), 'NERD') == 'NERD'
      wincmd c
      return
    endif

    if number_of_windows_to_this_buffer > 1
      wincmd c
    else
      bdelete
    endif
  endfunction "}}}

  " taken from stevelosh learnvimscriptthehardway
  function! GrepOperator(type)
    let saved_unnamed_register = @@

    if a:type ==# 'v'
      normal! `<v`>y
    elseif a:type ==# 'char'
      normal! `[v`]y
    else
      return
    endif

    " set the search register for the word
    let @/ = @@

    silent execute "Ack ". shellescape(@@) . " ."

    let @@ = saved_unnamed_register
  endfunction

  function! YankOnFocusGain() "{{{
    let @l = @*
  endfunction "}}}
  " backup the system copied data in l register
  augroup _sync_clipboard_system "{{{
    autocmd!
    autocmd FocusGained * call YankOnFocusGain()
  augroup END "}}}
"}}}

"set different filetypes {{{
augroup newFiletypes
  autocmd!
  autocmd BufNewFile,BufRead *.coffee set filetype=coffee
  autocmd FileType coffee so /Users/mohitaggarwal/.vim/coffeeplugin.vim
  autocmd BufNewFile,BufRead *.handlebars set filetype=handlebars
  autocmd BufNewFile,BufRead *.wiki set filetype=mediawiki
augroup END
"}}}

" base configuration {{{
  set timeoutlen=300                                  "mapping timeout
  set ttimeoutlen=50                                  "keycode timeout default set here was 50

  set mouse=a                                         "enable mouse
  set mousehide                                       "hide when characters are typed
  set history=1000                                    "number of command lines to remember
  set ttyfast                                         "assume fast terminal connection
  set viewoptions=folds,options,cursor,unix,slash     "unix/windows compatibility
  set encoding=utf-8                                  "set encoding for text
  set clipboard=unnamed                             "sync with OS clipboard
  set hidden                                          "allow buffer switching without saving
  set autoread                                        "auto reload if file saved externally
  set fileformats+=mac                                "add mac to auto-detection of file format line endings
  set nrformats-=octal                                "always assume decimal numbers
  set showcmd
  set tags=tags;/
  set showfulltag
  set modeline
  set modelines=5
  set nosol                                           "this keeps the cursor in the same column when you hit G in visual block mode
  set noshelltemp                                     "use pipes

  if s:is_windows && !s:is_cygwin
    " ensure correct shell in gvim
    set shell=c:\windows\system32\cmd.exe
  endif

  " whitespace
  set backspace=indent,eol,start                      "allow backspacing everything in insert mode
  set autoindent                                      "automatically indent to match adjacent lines
  set expandtab                                       "spaces instead of tabs
  set smarttab                                        "use shiftwidth to enter tabs
  let &tabstop=s:settings.default_indent              "number of spaces per tab for display
  let &softtabstop=s:settings.default_indent          "number of spaces per tab in insert mode
  let &shiftwidth=s:settings.default_indent           "number of spaces when indenting
  set list                                            "highlight whitespace
  set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮
  set shiftround
  set linebreak
  set diffopt=filler,vertical
  let &showbreak='↪ '

  set scrolloff=1                                     "always show content after scroll
  set scrolljump=5                                    "minimum number of lines to scroll
  set display+=lastline
  set wildmenu                                        "show list for autocomplete
  set wildmode=list:longest,full
  set wildignorecase
  " remove the wildignore as it is not used and it breaks fugitive
  " https://github.com/tpope/vim-fugitive/issues/121
  " set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store

  set splitbelow
  set splitright

  " disable sounds
  set noerrorbells
  set novisualbell
  set t_vb=

  " searching
  set hlsearch                                        "highlight searches
  set incsearch                                       "incremental searching
  set ignorecase                                      "ignore case for searching
  set smartcase                                       "do case-sensitive if there's a capital letter
  if executable('ack')
    set grepprg=ack\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow\ $*
    set grepformat=%f:%l:%c:%m
  endif

  " vim file/folder management {{{
    " persistent undo
    if exists('+undofile')
      set undofile
      set undodir=~/.vim/.cache/undo
    endif

    " backups
    set backup
    set backupdir=~/.vim/.cache/backup

    " swap files
    set directory=~/.vim/.cache/swap
    set noswapfile

    call EnsureExists('~/.vim/.cache')
    call EnsureExists(&undodir)
    call EnsureExists(&backupdir)
    call EnsureExists(&directory)
  "}}}

  let mapleader = ","
  let g:mapleader = ","
"}}}

" ui configuration {{{
  set showmatch                                       "automatically highlight matching braces/brackets/etc.
  set matchtime=2                                     "tens of a second to show matching parentheses
  set number
  set lazyredraw
  set laststatus=2
  set noshowmode
  set foldenable                                      "enable folds by default
  set foldmethod=syntax                               "fold via syntax of files
  set foldlevelstart=99                               "open all folds by default
  let g:xml_syntax_folding=1                          "enable xml folding

  set cursorline
  augroup fixcursorline
    autocmd!
    autocmd WinLeave * setlocal nocursorline
    autocmd WinEnter * setlocal cursorline
  augroup END
  let &colorcolumn=s:settings.max_column
  if s:settings.enable_cursorcolumn
    set cursorcolumn
    augroup restoreCursorline
      autocmd!
      autocmd WinLeave * setlocal nocursorcolumn
      autocmd WinEnter * setlocal cursorcolumn
    augroup END
  endif

  if has('conceal')
    set conceallevel=1
    set listchars+=conceal:Δ
  endif

  if has('gui_running')
    " open maximized
    set lines=999 columns=9999
    if s:is_windows
      augroup maximazeWindow
        autocmd!
        autocmd GUIEnter * simalt ~x
      augroup END
    endif

    set guioptions+=t                                 "tear off menu items
    set guioptions-=T                                 "toolbar icons

    if s:is_windows
      set gfn=Ubuntu_Mono:h10
    endif

    if has('gui_gtk')
      set gfn=Ubuntu\ Mono\ 11
    endif
  else
    if $COLORTERM == 'gnome-terminal'
      set t_Co=256 "why you no tell me correct colors?!?!
    endif
    if $TERM_PROGRAM == 'iTerm.app'
      " different cursors for insert vs normal mode
      if exists('$TMUX')
        let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
        let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
      else
        let &t_SI = "\<Esc>]50;CursorShape=1\x7"
        let &t_EI = "\<Esc>]50;CursorShape=0\x7"
      endif
    endif
  endif
"}}}

" plugin/mapping configuration {{{
  if count(s:settings.plugin_groups, 'core') "{{{

    NeoBundle 'AndrewRadev/splitjoin.vim'
    NeoBundle 't9md/vim-quickhl' "{{{
      nmap <leader>m <Plug>(quickhl-manual-this)
      xmap <leader>m <Plug>(quickhl-manual-this)
      nmap <leader>M <Plug>(quickhl-manual-reset)
      xmap <leader>M <Plug>(quickhl-manual-reset)
    "}}}
    NeoBundle 'ton/vim-bufsurf'
    NeoBundle 'epeli/slimux'

    " try out differnt ideas in a very simple way
    NeoBundle 't9md/vim-tryit' "{{{
      let g:tryit_dir = "/tmp"
      nmap T <Plug>(tryit-this)
      xmap T <Plug>(tryit-this)
      nmap <leader>t <Plug>(tryit-ask)
      xmap <leader>t <Plug>(tryit-ask)
      nmap <leader>tp :Tryit py<cr>
      nmap <leader>tc :Tryit clj<cr>
    "}}}
    NeoBundle 'matchit.zip'
    NeoBundle 'bling/vim-airline' "{{{
      let g:airline#extensions#tabline#enabled = 1
      let g:airline_powerline_fonts = 1
      let g:airline_theme="luna"
    "}}}
    NeoBundle 'tpope/vim-surround'
    " rainbow parentheses for lisp like languages
    NeoBundle 'amdt/vim-niji'

    " this plugin overrides the default text objects in vim and first make them multiline and also provides
    " some new operators such as , _ etc
    NeoBundle 'wellle/targets.vim'
    NeoBundle 'tpope/vim-sleuth'
    NeoBundle 'tpope/vim-repeat'
    NeoBundle 'Peeja/vim-cdo'
    " breaks ack.vim
    " NeoBundle 'tpope/vim-dispatch'
    NeoBundle 'tpope/vim-eunuch'
    NeoBundle 'tpope/vim-unimpaired' "{{{
      nmap <c-up> [e
      nmap <c-down> ]e
      vmap <c-up> [egv
      vmap <c-down> ]egv
    "}}}
    "this plugin can toggle between true and false and a whole lot more
    NeoBundle 'AndrewRadev/switch.vim' " {{{
    nnoremap <c-c> :Switch<cr>
    " }}}
    NeoBundle 'Shougo/vimproc.vim', {
      \ 'build': {
        \ 'mac': 'make -f make_mac.mak',
        \ 'unix': 'make -f make_unix.mak',
        \ 'cygwin': 'make -f make_cygwin.mak',
        \ 'windows': '"C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\nmake.exe" make_msvc32.mak',
      \ },
    \ }
  endif "}}}

  if count(s:settings.plugin_groups, 'web') "{{{
    NeoBundleLazy 'mustache/vim-mustache-handlebars', {'autoload':{'filetypes':['handlebars']}}
    NeoBundleLazy 'groenewege/vim-less', {'autoload':{'filetypes':['less']}}
    NeoBundleLazy 'cakebaker/scss-syntax.vim', {'autoload':{'filetypes':['scss','sass']}}
    NeoBundleLazy 'hail2u/vim-css3-syntax', {'autoload':{'filetypes':['css','scss','sass']}}
    NeoBundleLazy 'ap/vim-css-color', {'autoload':{'filetypes':['css','scss','sass','less','styl']}}
    " NeoBundleLazy 'othree/html5.vim', {'autoload':{'filetypes':['html']}}
    NeoBundleLazy 'wavded/vim-stylus', {'autoload':{'filetypes':['styl']}}
    NeoBundleLazy 'digitaltoad/vim-jade', {'autoload':{'filetypes':['jade']}}
    NeoBundleLazy 'juvenn/mustache.vim', {'autoload':{'filetypes':['mustache']}}
    NeoBundleLazy 'gregsexton/MatchTag', {'autoload':{'filetypes':['html','xml']}}
    NeoBundleLazy 'mattn/emmet-vim', {'autoload':{'filetypes':['html','xml','xsl','xslt','xsd','css','sass','scss','less','mustache']}} "{{{
      " function! s:zen_html_tab()
      "   let line = getline('.')
      "   if match(line, '\v\s*.*>') !=# 0
      "     return "\<c-y>,"
      "   endif
      "   return "\<c-y>n"
      " endfunction
      " autocmd FileType xml,xsl,xslt,xsd,css,sass,scss,less,mustache imap <buffer><tab> <c-y>,
      " autocmd FileType html imap <buffer><expr><C-c> <sid>zen_html_tab()
      autocmd FileType html nmap <leader>r <C-y>,
    "}}}
  endif "}}}
  if count(s:settings.plugin_groups, 'javascript') "{{{
    NeoBundleLazy 'marijnh/tern_for_vim', {
      \ 'autoload': { 'filetypes': ['javascript', 'coffee'] },
      \ 'build': {
        \ 'mac': 'npm install',
        \ 'unix': 'npm install',
        \ 'cygwin': 'npm install',
        \ 'windows': 'npm install',
      \ },
    \ }
    " {{{
        " tern config
        let g:tern_map_keys=1
        let g:tern_show_argument_hits='on_hold'
    " }}}
    NeoBundleLazy 'othree/tern_for_vim_coffee', { 'filetypes':['coffee'] }
    NeoBundle 'mohitleo9/vim-fidget',{
            \ 'build' : {
            \    'unix' : 'npm install',
            \    'mac' : 'npm install',
            \ },
      \}
    " NeoBundleLazy 'pangloss/vim-javascript', {'autoload':{'filetypes':['javascript']}}
    NeoBundleLazy 'jelera/vim-javascript-syntax', {'autoload':{'filetypes':['javascript']}}
    NeoBundleLazy 'maksimr/vim-jsbeautify', {'autoload':{'filetypes':['javascript']}} "{{{
      nnoremap <leader>fjs :call JsBeautify()<cr>
    "}}}
    NeoBundleLazy 'leafgarland/typescript-vim', {'autoload':{'filetypes':['typescript']}}
    NeoBundleLazy 'matthewsimo/angular-vim-snippets', {'autoload':{'filetypes':['coffee', 'javascript']}}
    NeoBundleLazy 'kchmck/vim-coffee-script', {'autoload':{'filetypes':['coffee']}} "{{{
    " }}}

    " NeoBundleLazy 'mmalecki/vim-node.js', {'autoload':{'filetypes':['javascript']}}
    NeoBundleLazy 'elzr/vim-json', {'autoload':{'filetypes':['javascript','json']}} "{{{
    let g:vim_json_syntax_conceal = 0
    " this line calls the python json tool to format the json object for json file when used like gg=G
    augroup formatjson
      autocmd!
      autocmd FileType json setlocal equalprg=python\ -m\ json.tool
    augroup END
    " }}}

    " othree/javascript-libraries-syntax.vim conflicts with coffeescript
    NeoBundleLazy 'othree/javascript-libraries-syntax.vim', {'autoload':{'filetypes':['javascript','typescript']}}
  endif "}}}
  if count(s:settings.plugin_groups, 'ruby') "{{{
    NeoBundle 'tpope/vim-rails'
    NeoBundle 'tpope/vim-bundler'
  endif "}}}
  if count(s:settings.plugin_groups, 'python') "{{{
    NeoBundleLazy 'klen/python-mode', {'autoload':{'filetypes':['python']}} "{{{
      let g:pymode_rope=0
      let g:pymode_run = 0
      let g:pymode_lint = 0
      let g:pymode_folding = 0
    "}}}
    " NeoBundleLazy 'hdima/python-syntax', {'autoload': {'filetypes':['python']}}
    " disable jedi if ycm is used as it is a part of ycm as a submodule
    if !s:settings.autocomplete_method == 'ycm'
      NeoBundleLazy 'davidhalter/jedi-vim', {'autoload':{'filetypes':['python']}} "{{{
        let g:jedi#popup_on_dot=0
      "}}}
    endif
  endif "}}}
  if count(s:settings.plugin_groups, 'scala') "{{{
    NeoBundle 'derekwyatt/vim-scala'
    NeoBundle 'megaannum/vimside'
  endif "}}}

  if count(s:settings.plugin_groups, 'clojure') "{{{
    NeoBundle 'guns/vim-clojure-static'
    NeoBundle 'guns/vim-sexp' "{{{
      let g:sexp_enable_insert_mode_mappings = 0
    " }}}
    NeoBundle 'tpope/vim-fireplace'
    NeoBundle 'tpope/vim-sexp-mappings-for-regular-people'
    NeoBundle 'dgrnbrg/vim-redl'
  endif "}}}

  if count(s:settings.plugin_groups, 'go') "{{{
    NeoBundleLazy 'jnwhiteh/vim-golang', {'autoload':{'filetypes':['go']}}
    NeoBundleLazy 'nsf/gocode', {'autoload': {'filetypes':['go']}, 'rtp': 'vim'}
  endif "}}}
  if count(s:settings.plugin_groups, 'scm') "{{{
    NeoBundle 'mhinz/vim-signify' "{{{
      let g:signify_update_on_focusgained = 1
    "}}}
    if executable('hg')
      NeoBundle 'bitbucket:ludovicchabant/vim-lawrencium'
    endif
    NeoBundle 'tpope/vim-fugitive' "{{{
      nnoremap <silent> <leader>gs :Gstatus<CR>
      nnoremap <silent> <leader>gd :Gdiff<CR>
      nnoremap <silent> <leader>gc :Gcommit<CR>
      nnoremap <silent> <leader>gb :Gblame<CR>
      nnoremap <silent> <leader>gg :Ggrep<cword><CR>
      nnoremap <silent> <leader>gl :Glog<CR>
      nnoremap <silent> <leader>gp :Git push<CR>
      nnoremap <silent> <leader>gw :Gwrite<CR>
      nnoremap <silent> <leader>gr :Gremove<CR>

      augroup _fugitive_buffer_delete
        autocmd!
        autocmd FileType gitcommit nmap <buffer> U :Git checkout -- <C-r><C-g><CR>
        autocmd BufReadPost fugitive://* set bufhidden=delete
      augroup END
    "}}}
    NeoBundle 'tpope/vim-git'
    NeoBundleLazy 'gregsexton/gitv', {'depends':['tpope/vim-fugitive'], 'autoload':{'commands':'Gitv'}} "{{{
      nnoremap <silent> <leader>gv :Gitv<CR>
      let g:Gitv_DoNotMapCtrlKey = 0
      nnoremap <silent> <leader>gV :Gitv!<CR>
    "}}}
  endif "}}}
  if count(s:settings.plugin_groups, 'autocomplete') "{{{
    NeoBundle 'honza/vim-snippets'
    if s:settings.autocomplete_method == 'ycm' "{{{
      NeoBundle 'Valloric/YouCompleteMe', {
            \ 'build' : {
            \    'unix' : './install.sh --clang-completer',
            \    'mac' : './install.sh --clang-completer',
            \ },
      \} "{{{
        let g:ycm_complete_in_comments_and_strings=1
        nnoremap <leader>jd :YcmCompleter GoTo<CR>
        let g:ycm_collect_identifiers_from_comments_and_strings = 1
        " let g:ycm_key_list_select_completion=['<C-n>', '<Down>']
        " let g:ycm_key_list_previous_completion=['<C-p>', '<Up>']
        " let g:ycm_filetype_blacklist={'unite': 1}
      "}}}
      NeoBundle 'SirVer/ultisnips' "{{{
        let g:UltiSnipsExpandTrigger = '<C-j>'
        let g:UltiSnipsJumpForwardTrigger = '<C-j>'
        let g:UltiSnipsJumpBackwardTrigger = '<C-k>'
        " let g:UltiSnipsExpandTrigger="<tab>"
        " let g:UltiSnipsJumpForwardTrigger="<tab>"
        " let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
        " let g:UltiSnipsSnippetsDir='~/.vim/snippets'
      "}}}
    else
      NeoBundle 'Shougo/neosnippet-snippets'
      NeoBundle 'Shougo/neosnippet.vim' "{{{
        let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets,~/.vim/snippets'
        let g:neosnippet#enable_snipmate_compatibility=1

        imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ? "\<C-n>" : "\<TAB>")
        smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
        imap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
        smap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
      "}}}
    endif "}}}
    if s:settings.autocomplete_method == 'neocomplete' "{{{
      NeoBundleLazy 'Shougo/neocomplete.vim', {'autoload':{'insert':1}, 'vim_version':'7.3.885'} "{{{
        let g:neocomplete#enable_at_startup=1
        let g:neocomplete#data_directory='~/.vim/.cache/neocomplete'
      "}}}
    endif "}}}
    if s:settings.autocomplete_method == 'neocomplcache' "{{{
      NeoBundleLazy 'Shougo/neocomplcache.vim', {'autoload':{'insert':1}} "{{{
        let g:neocomplcache_enable_at_startup=1
        let g:neocomplcache_temporary_dir='~/.vim/.cache/neocomplcache'
        let g:neocomplcache_enable_fuzzy_completion=1
      "}}}
    endif "}}}
  endif "}}}
  if count(s:settings.plugin_groups, 'editing') "{{{
    " NeoBundleLazy 'editorconfig/editorconfig-vim', {'autoload':{'insert':1}}
    NeoBundle 'tpope/vim-endwise'
    NeoBundle 'jaxbot/semantic-highlight.vim'
      nnoremap <Leader>se :SemanticHighlightToggle<cr>
    NeoBundle 'tpope/vim-speeddating'
    NeoBundle 'thinca/vim-visualstar'
    NeoBundle 'tomtom/tcomment_vim'
    NeoBundle 'terryma/vim-multiple-cursors'
    NeoBundleLazy 'godlygeek/tabular', {'autoload':{'commands':'Tabularize'}} "{{{
      nmap <Leader>a& :Tabularize /&<CR>
      vmap <Leader>a& :Tabularize /&<CR>
      nmap <Leader>a= :Tabularize /=<CR>
      vmap <Leader>a= :Tabularize /=<CR>
      nmap <Leader>a: :Tabularize /:<CR>
      vmap <Leader>a: :Tabularize /:<CR>
      nmap <Leader>a:: :Tabularize /:\zs<CR>
      vmap <Leader>a:: :Tabularize /:\zs<CR>
      nmap <Leader>a, :Tabularize /,<CR>
      vmap <Leader>a, :Tabularize /,<CR>
      nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
      vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
    "}}}
    " Interferes with clojure
    NeoBundle 'kana/vim-smartinput'
    NeoBundle 'Lokaltog/vim-easymotion' "{{{
    " replace the default search not kidding
    " use smartcase
      let g:EasyMotion_smartcase = 1
      map  / <Plug>(easymotion-sn)
      omap / <Plug>(easymotion-tn)
      map  n <Plug>(easymotion-next)
      map  N <Plug>(easymotion-prev)
    "}}}
  endif "}}}
  if count(s:settings.plugin_groups, 'navigation') "{{{
    NeoBundle 'mileszs/ack.vim' "{{{
      if executable('ag')
        let g:ackprg = "ag --nogroup --column --smart-case --follow"
      endif
    "}}}
    NeoBundleLazy 'sjl/gundo.vim', {'autoload':{'commands':'GundoToggle'}} "{{{
      let g:gundo_preview_bottom=1
      let g:gundo_width=30
      nnoremap <silent> <F5> :GundoToggle<CR>
    "}}}
    NeoBundle 'kien/ctrlp.vim', { 'depends': 'tacahiroy/ctrlp-funky' } "{{{
      let g:ctrlp_use_caching = 0
      " let g:ctrlp_clear_cache_on_exit=1
      let g:ctrlp_max_height=40
      let g:ctrlp_show_hidden=0
      let g:ctrlp_follow_symlinks=1
      let g:ctrlp_working_path_mode = 'ra'
      let g:ctrlp_max_files=20000
      let g:ctrlp_cache_dir='~/.vim/.cache/ctrlp'
      let g:ctrlp_reuse_window='startify'
      let g:ctrlp_extensions=['funky']

      let g:ctrlp_custom_ignore = {
            \ 'dir':  '\.git$\|\.hg$\|\.svn$',
            \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }

      " On Windows use "dir" as fallback command.
      if s:is_windows
        let s:ctrlp_fallback = 'dir %s /-n /b /s /a-d'
      elseif executable('ag')
        let s:ctrlp_fallback = 'ag %s --nocolor -l -g ""'
      elseif executable('ack')
        let s:ctrlp_fallback = 'ack %s --nocolor -f'
      else
        let s:ctrlp_fallback = 'find %s -type f'
      endif
      let g:ctrlp_user_command = {
            \ 'types': {
            \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
            \ 2: ['.hg', 'hg --cwd %s locate -I .'],
            \ },
            \ 'fallback': s:ctrlp_fallback
            \ }

      nmap \ [ctrlp]
      nnoremap [ctrlp] <nop>

      nnoremap [ctrlp]t :CtrlPBufTag<cr>
      nnoremap [ctrlp]T :CtrlPTag<cr>
      nnoremap [ctrlp]l :CtrlPLine<cr>
      nnoremap [ctrlp]o :CtrlPFunky<cr>
      nnoremap [ctrlp]b :CtrlPBuffer<cr>
    "}}}
  endif "}}}
  if count(s:settings.plugin_groups, 'unite') "{{{
    NeoBundle 'Shougo/unite.vim' "{{{
      let bundle = neobundle#get('unite.vim')
      function! bundle.hooks.on_source(bundle)
        call unite#filters#matcher_default#use(['matcher_fuzzy'])
        call unite#filters#sorter_default#use(['sorter_rank'])
        " call unite#set_profile('files', 'smartcase', 1)
        call unite#custom#source('line,outline','matchers','matcher_fuzzy')
        call unite#custom#profile('default', 'context', {
              \ 'start_insert': 1,
              \ 'direction': 'botright',
              \ })
        " call unite#custom#source('line,outline','matchers','matcher_fuzzy')
      endfunction

      let g:unite_data_directory='~/.vim/.cache/unite'
      let g:unite_enable_start_insert=1
      let g:unite_source_history_yank_enable=1
      let g:unite_source_rec_max_cache_files=5000
      let g:unite_prompt='» '
      if executable('ag')
        let g:unite_source_rec_async_command='ag --nocolor --nogroup --ignore ".hg" --ignore ".svn" --ignore ".git" --ignore ".bzr" --hidden -g ""'
        let g:unite_source_grep_command='ag'
        let g:unite_source_grep_default_opts='--nocolor --nogroup -S -C4'
        let g:unite_source_grep_recursive_opt=''
      elseif executable('ack')
        let g:unite_source_grep_command='ack'
        let g:unite_source_grep_default_opts='--no-heading --no-color -a -C4'
        let g:unite_source_grep_recursive_opt=''
      endif

      function! s:unite_settings()
        nmap <buffer> Q <plug>(unite_exit)
        nmap <buffer> <esc> <plug>(unite_exit)
        imap <buffer> <esc> <plug>(unite_exit)
      endfunction

      augroup _unite_settings
        autocmd!
        autocmd FileType unite call s:unite_settings()
      augroup END

      nmap <space> [unite]
      nnoremap [unite] <nop>

      if s:is_windows
        nnoremap <silent> [unite]f :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec:! buffer file_mru bookmark<cr><c-u>
        nnoremap <silent> [unite]<space> :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec:!<cr><c-u>
      else
        nnoremap <silent> [unite]f :<C-u>Unite -toggle -auto-resize -buffer-name=mixed buffer:! file_rec/async bookmark<cr><c-u>
        nnoremap <silent> [unite]<space> :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec/async:!<cr><c-u>
      endif
      nnoremap <silent> [unite]e :<C-u>Unite -buffer-name=recent file_mru<cr>

      " Quick history needs plugin
      " nnoremap <silent> [unite]; :<C-u>Unite -buffer-name=history history/command command<CR>

      " Quick commands
      nnoremap <silent> [unite]c :<C-u>Unite -buffer-name=commands command<CR>

      nnoremap <silent> [unite]y :<C-u>Unite -buffer-name=yanks history/yank<cr>
      nnoremap <silent> [unite]l :<C-u>Unite -auto-resize -buffer-name=line line<cr>
      nnoremap <silent> [unite]b :<C-u>Unite -auto-resize -buffer-name=buffers buffer<cr>
      nnoremap <silent> [unite]/ :<C-u>Unite -no-quit -buffer-name=search grep:.<cr>
      nnoremap <silent> [unite]m :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
      " nnoremap <silent> [unite]s :<C-u>Unite -quick-match buffer<cr>
    "}}}
    NeoBundleLazy 'Shougo/neomru.vim', {'autoload':{'unite_sources':'file_mru'}}
    NeoBundleLazy 'osyo-manga/unite-airline_themes', {'autoload':{'unite_sources':'airline_themes'}} "{{{
      nnoremap <silent> [unite]a :<C-u>Unite -winheight=10 -auto-preview -buffer-name=airline_themes airline_themes<cr>
    "}}}
    NeoBundleLazy 'ujihisa/unite-colorscheme', {'autoload':{'unite_sources':'colorscheme'}} "{{{
      nnoremap <silent> [unite]s :<C-u>Unite -winheight=10 -auto-preview -buffer-name=colorschemes colorscheme<cr>
    "}}}
    NeoBundleLazy 'tsukkee/unite-tag', {'autoload':{'unite_sources':['tag','tag/file']}} "{{{
      nnoremap <silent> [unite]t :<C-u>Unite -auto-resize -buffer-name=tag tag tag/file<cr>
    "}}}
    NeoBundleLazy 'Shougo/unite-outline', {'autoload':{'unite_sources':'outline'}} "{{{
      nnoremap <silent> [unite]o :<C-u>Unite -auto-resize -buffer-name=outline outline<cr>
    "}}}
    NeoBundleLazy 'Shougo/unite-help', {'autoload':{'unite_sources':'help'}} "{{{
      nnoremap <silent> [unite]h :<C-u>Unite -auto-resize -buffer-name=help help<cr>
    "}}}
    NeoBundleLazy 'Shougo/junkfile.vim', {'autoload':{'commands':'JunkfileOpen','unite_sources':['junkfile','junkfile/new']}} "{{{
      let g:junkfile#directory=expand("~/.vim/.cache/junk")
      nnoremap <silent> [unite]j :<C-u>Unite -auto-resize -buffer-name=junk junkfile junkfile/new<cr>
    "}}}
  endif "}}}
  if count(s:settings.plugin_groups, 'indents') "{{{
    " this plugin has performance issues so can be disabled if causing problems
    " NeoBundle 'Yggdroot/indentLine' "{{{
      " let g:indentLine_faster = 1
    "}}}

    " NeoBundle 'nathanaelkane/vim-indent-guides' "{{{
    "   let g:indent_guides_start_level=1
    "   let g:indent_guides_guide_size=1
    "   let g:indent_guides_enable_on_vim_startup=0
    "   let g:indent_guides_color_change_percent=3
    "   if !has('gui_running')
    "     let g:indent_guides_auto_colors=0
    "     function! s:indent_set_console_colors()
    "       hi IndentGuidesOdd ctermbg=235
    "       hi IndentGuidesEven ctermbg=236
    "     endfunction
    "     autocmd VimEnter,Colorscheme * call s:indent_set_console_colors()
    "   endif
    " "}}}
  endif "}}}
  if count(s:settings.plugin_groups, 'textobj') "{{{
    NeoBundle 'kana/vim-textobj-user'
    NeoBundle 'kana/vim-textobj-line'
    NeoBundle 'kana/vim-textobj-indent'
    NeoBundle 'kana/vim-textobj-entire'
    " NeoBundle 'lucapette/vim-textobj-underscore'
  endif "}}}
  if count(s:settings.plugin_groups, 'misc') "{{{
    if exists('$TMUX')
      NeoBundle 'christoomey/vim-tmux-navigator'
    endif
    " NeoBundle 'kana/vim-vspec'
    NeoBundleLazy 'tpope/vim-scriptease', {'autoload':{'filetypes':['vim']}}
    NeoBundle 'chrisbra/csv.vim'
    NeoBundleLazy 'tpope/vim-markdown', {'autoload':{'filetypes':['markdown']}}
    NeoBundleLazy 'chikamichi/mediawiki.vim', {'autoload':{'filetypes':['mediawiki']}}
    if executable('redcarpet') && executable('instant-markdown-d')
      NeoBundleLazy 'suan/vim-instant-markdown', {'autoload':{'filetypes':['markdown']}}
    endif
    NeoBundleLazy 'guns/xterm-color-table.vim', {'autoload':{'commands':'XtermColorTable'}}
    " NeoBundle 'chrisbra/vim_faq'
    " NeoBundle 'vimwiki'
    " NeoBundle 'rosenfeld/conque-term'
    NeoBundle 'junegunn/goyo.vim', "  {{{
      let g:goyo_width=150
      let g:goyo_margin_top=2
      let g:goyo_margin_bottom=2
    " }}}
    NeoBundle 'bufkill.vim'
    NeoBundle 'mhinz/vim-startify' "{{{
      let g:startify_session_dir = '~/.vim/.cache/sessions'
      let g:startify_change_to_vcs_root = 1
      let g:startify_show_sessions = 1
      nnoremap <F1> :Startify<cr>
    "}}}
    NeoBundle 'scrooloose/syntastic' "{{{
      let g:syntastic_coffee_coffeelint_args = "-f ~/.vim/bundle/vim-coffee-script/lintRules/coffeelint.json"
      let g:syntastic_error_symbol = '✗'
      let g:syntastic_style_error_symbol = '✠'
      let g:syntastic_warning_symbol = '∆'
      let g:syntastic_style_warning_symbol = '≈'
      let g:syntastic_aggregate_errors = 1
    "}}}
    NeoBundleLazy 'mattn/gist-vim', { 'depends': 'mattn/webapi-vim', 'autoload': { 'commands': 'Gist' } } "{{{
      let g:gist_post_private=1
      let g:gist_show_privates=1
    "}}}

      nnoremap <leader>c :VimShell -split<cr>
      nnoremap <leader>cc :VimShell -split<cr>
      nnoremap <leader>cn :VimShellInteractive node<cr>
      nnoremap <leader>cl :VimShellInteractive lua<cr>
      nnoremap <leader>cr :VimShellInteractive irb<cr>
      nnoremap <leader>cp :VimShellInteractive python<cr>
    "}}}
    NeoBundleLazy 'zhaocai/GoldenView.Vim', {'autoload':{'mappings':['<Plug>ToggleGoldenViewAutoResize']}} "{{{
      let g:goldenview__enable_default_mapping=0
      nmap <F4> <Plug>ToggleGoldenViewAutoResize
    "}}}
  endif "}}}
  if count(s:settings.plugin_groups, 'windows') "{{{
    NeoBundleLazy 'PProvost/vim-ps1', {'autoload':{'filetypes':['ps1']}}
    NeoBundleLazy 'nosami/Omnisharp', {'autoload':{'filetypes':['cs']}}
  endif "}}}

" mappings {{{
"  eval vimscript by line or visual selection
  nmap <silent> <leader>e :call Source(line('.'), line('.'))<CR>
  vmap <silent> <leader>e :call Source(line('v'), line('.'))<CR>

  " grep operator (technically ack)
  nnoremap g/ :set operatorfunc=GrepOperator<cr>g@
  vnoremap g/ :<c-u>call GrepOperator(visualmode())<cr>

  " formatting shortcuts
  nmap <leader>fef :call Preserve("normal gg=G")<CR>
  nmap <leader>f$ :call StripTrailingWhitespace()<CR>
  vmap <leader>s :sort<cr>

  nnoremap <leader>w :w<cr>

  " toggle paste
  map <F6> :set invpaste<CR>:set paste?<CR>

  " remap arrow keys
  nnoremap <left> :bprev<CR>
  nnoremap <right> :bnext<CR>
  nnoremap <up> :tabnext<CR>
  nnoremap <down> :tabprev<CR>

  " change cursor position in insert mode
  inoremap <C-h> <left>
  inoremap <C-l> <right>

  inoremap <C-u> <C-g>u<C-u>

  if mapcheck('<space>/') == ''
    nnoremap <space>/ :vimgrep //gj **/*<left><left><left><left><left><left><left><left>
  endif

  " sane regex {{{
    nnoremap ? ?\v
    vnoremap ? ?\v
    nnoremap :s/ :s/\v
  " }}}

  " command-line window {{{
    nnoremap q: q:i
    nnoremap q/ q/i
    nnoremap q? q?i
  " }}}

  " folds {{{
    nnoremap zr zr:echo &foldlevel<cr>
    nnoremap zm zm:echo &foldlevel<cr>
    nnoremap zR zR:echo &foldlevel<cr>
    nnoremap zM zM:echo &foldlevel<cr>
  " }}}

  " screen line scroll
  nnoremap <silent> j gj
  nnoremap <silent> k gk

  " auto center {{{
    nnoremap <silent> n nzz
    nnoremap <silent> N Nzz
    nnoremap <silent> * *zz
    nnoremap <silent> # #zz
    nnoremap <silent> g* g*zz
    nnoremap <silent> g# g#zz
    nnoremap <silent> <C-o> <C-o>zz
    nnoremap <silent> <C-i> <C-i>zz
  "}}}

  " reselect visual block after indent
  vnoremap < <gv
  vnoremap > >gv

  " reselect last paste
  nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

  " find current word in quickfix
  nnoremap <leader>fw :execute "vimgrep ".expand("<cword>")." %"<cr>:copen<cr>
  " find last search in quickfix
  nnoremap <leader>ff :execute 'vimgrep /'.@/.'/g %'<cr>:copen<cr>

  " shortcuts for windows {{{
    nnoremap <leader>v <C-w>v<C-w>l
    nnoremap <leader>s <C-w>s
    nnoremap <leader>vsa :vert sba<cr>
    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l
  "}}}

  " make Y consistent with C and D. See :help Y.
  nnoremap Y y$

  " hide annoying quit message
  " nnoremap <C-c> <C-c>:echo<cr>

  " window killer
  nnoremap <silent> Q :call CloseWindowOrKillBuffer()<cr>

  " quick buffer open
  nnoremap gb :ls<cr>:e #

  if neobundle#is_sourced('vim-dispatch')
    nnoremap <leader>tag :Dispatch ctags -R<cr>
  endif

  " general
  nmap <leader>l :set list! list?<cr>
  nnoremap <BS> :set hlsearch! hlsearch?<cr>

  map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
        \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
        \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

  " helpers for profiling {{{
    nnoremap <silent> <leader>dd :exe ":profile start profile.log"<cr>:exe ":profile func *"<cr>:exe ":profile file *"<cr>
    nnoremap <silent> <leader>dp :exe ":profile pause"<cr>
    nnoremap <silent> <leader>dc :exe ":profile continue"<cr>
    nnoremap <silent> <leader>dq :exe ":profile pause"<cr>:noautocmd qall!<cr>
  "}}}
"}}}
"better yank and paste to the end of line
"easy to repeat paste
"this is genius credit http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" commands {{{
  command! -bang Q q<bang>
  command! -bang QA qa<bang>
  command! -bang Qa qa<bang>
"}}}

" autocmd {{{
  " go back to previous position of cursor if any
  augroup variousCommands
    autocmd!
    autocmd BufReadPost *
          \ if line("'\"") > 0 && line("'\"") <= line("$") |
          \  exe 'normal! g`"zvzz' |
          \ endif

    autocmd FileType js,scss,css,python,coffee,vim,clojure autocmd BufWritePre <buffer> call StripTrailingWhitespace()
    autocmd FileType css,scss setlocal foldmethod=marker foldmarker={,}
    autocmd FileType css,scss nnoremap <silent> <leader>S vi{:sort<CR>
    autocmd FileType python setlocal foldmethod=indent
    autocmd FileType markdown setlocal nolist
    autocmd FileType vim setlocal fdm=indent keywordprg=:help
  augroup END
"}}}

" color schemes {{{
  NeoBundle 'morhetz/gruvbox'
  NeoBundle 'altercation/vim-colors-solarized' "{{{
    " let g:solarized_termcolors=256
    " let g:solarized_termtrans=1
  "}}}
  NeoBundle 'nanotech/jellybeans.vim'
  NeoBundle 'tomasr/molokai'
  " this plugin highilghts the color for hex value
  NeoBundle 'lilydjwg/colorizer' " {{{
    let g:colorizer_nomap = 1
  " }}}
  NeoBundle 'morhetz/gruvbox'
  NeoBundle 'chriskempson/vim-tomorrow-theme'
  NeoBundle 'chriskempson/base16-vim'
  NeoBundle 'w0ng/vim-hybrid'
  NeoBundle 'sjl/badwolf'
  NeoBundle 'junegunn/seoul256.vim'
  NeoBundle 'zeis/vim-kolor' "{{{
    let g:kolor_underlined=1
  "}}}

"}}}

" finish loading {{{
  if exists('g:dotvim_settings.disabled_plugins')
    for plugin in g:dotvim_settings.disabled_plugins
      exec 'NeoBundleDisable '.plugin
    endfor
  endif

  call neobundle#end()

  filetype plugin indent on
  syntax enable

  NeoBundleCheck

  exec 'colorscheme '.s:settings.colorscheme
"}}}
