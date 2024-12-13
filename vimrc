" Do not run defaults vim, that can enable mouse mode and other stuff
"
" Defaults:
" - /usr/share/vim/vim80/defaults.vim (debian)
let g:skip_defaults_vim=1

runtime! debian.vim
runtime! archlinux.vim

" Load vim-plug
if empty(glob("~/.vim/autoload/plug.vim"))
  execute '!curl --create-dirs -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

call plug#begin('~/.vim/bundle')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'azat-archive/coc-yaml', {'branch': 'next', 'do': 'yarn install --frozen-lockfile'}
Plug 'yaegassy/coc-ruff', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
" for now ruff does not support completion
Plug 'yaegassy/coc-pylsp', {'do': 'yarn install --frozen-lockfile'}
Plug 'yaegassy/coc-ansible', {'do': 'yarn install --frozen-lockfile'}
" has additional commands
Plug 'clangd/coc-clangd', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'junegunn/fzf' " dependency of fzf.vim
Plug 'junegunn/fzf.vim'
Plug 'sunaku/vim-shortcut'
Plug 'szw/vim-tags'
Plug 'vim-scripts/taglist.vim'
Plug 'ciaranm/detectindent'
Plug 'godlygeek/tabular'
Plug 'svermeulen/vim-easyclip'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-commentary'
Plug 'sjl/gundo.vim'
Plug 'itchyny/lightline.vim'
Plug 'tmux-plugins/vim-tmux'
Plug 'pearofducks/ansible-vim' " , { 'do': 'cd ./UltiSnips; ./generate.py' }
Plug 'mmarchini/bpftrace.vim'
Plug 'mg979/vim-visual-multi'
Plug 'sakshamgupta05/vim-todo-highlight'
" Plug 'crusoexia/vim-monokai'
" Plug 'ericbn/vim-solarized'
Plug 'folke/tokyonight.nvim'
Plug 'hashivim/vim-terraform'
Plug 'rust-lang/rust.vim'
call plug#end()

function! PlugLoaded(name)
    " FIXME: take into account stridx(&rtp, g:plugs[a:name].dir) >= 0)
    " (but now it does not work)
    return (
        \ has_key(g:plugs, a:name) &&
        \ isdirectory(g:plugs[a:name].dir))
endfunction

"
" basic
"
set tags=tags;/
set mouse=
set guicursor=
set number
set hidden
set termencoding=utf-8
set fileencodings=utf8,cp1251
set encoding=utf8
set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯЖ;ABCDEFGHIJKLMNOPQRSTUVWXYZ:,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
set tw=0
set hlsearch
set incsearch
set fileformat=unix
set wildmenu
set laststatus=2
set wcm=<Tab>
set splitbelow
if &term =~ '^screen'
  " tmux will send xterm-style keys when its xterm-keys option is on
  execute "set <xUp>=\e[1;*A"
  execute "set <xDown>=\e[1;*B"
  execute "set <xRight>=\e[1;*C"
  execute "set <xLeft>=\e[1;*D"
endif
if $TERM =~ '^\(xterm\|tmux\|rxvt\)' && has('nvim')
  set termguicolors
endif
try
  colorscheme tokyonight-night
catch
  colorscheme desert
endtry
" Transparent background
highlight Normal guibg=NONE ctermbg=NONE
highlight EndOfBuffer guibg=NONE ctermbg=NONE

" autoread/autowrite
set autowrite
set autoread
if has('nvim')
  " Apparently autoread does not always works in nvim, in particular I need
  " after SIGSTOP/SIGCONT (C-z/fg) - VimResume.
  "
  " See also:
  " - https://github.com/neovim/neovim/issues/1380
  " - https://github.com/neovim/neovim/issues/1936
  autocmd FocusGained,BufEnter,CursorHold,CursorHoldI,VimResume *
      \ if mode() != 'c' | checktime | endif

  " mostly due to trim_trailing_whitespace
  let g:editorconfig = v:false
endif

exec "set listchars=tab:\uBB\uBB,trail:\uB7,nbsp:~"
set list

" Make the 81st column stand out
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 100)

" ignores
set wildignore+=*/.git/**,*/.hg/**,*/.svn/**,*/.cmake**,*/.bld**
set wildignore+=*/build/**,*/__pycache__/**,*/.egg-info/**
set wildignore+=*.exe,*.so,*.dll,*.a,*.o
set wildignore+=*.la,*.lo,*.pc,*.in
set wildignore+=*.sw[poa]
set wildignore+=*.zip,*.rar,*.tgz,*.gz,*.tar,*.zst,*.bgz
set wildignore+=*.pyc,*.whl

" no backup needed
set nobackup
set nowb
set noswapfile
" Open any file with a pre-existing swapfile in readonly mode
augroup NoSimultaneousEdits
  autocmd!
  autocmd SwapExists * let v:swapchoice = 'o'
  autocmd SwapExists * echoerr 'Duplicate edit session (readonly)'
augroup END

"
" vim-tags
"
let g:vim_tags_directories = [ ".git/.." ]
let g:vim_tags_auto_generate = 0
let g:vim_tags_project_tags_command = "flock -n /tmp/vim-ctags.lock {CTAGS} -R {OPTIONS} {DIRECTORY} 2>/dev/null"

"
" lightline
"
function! LinterStatus() abort
  if exists('b:coc_enabled')
    return coc#status()
  else
    return ""
  endif
endfunction
function! StatusFileName()
  return expand('%:p')
endfunction
let g:lightline = {
  \   'colorscheme': 'seoul256',
  \   'active': {
  \     'left': [
  \       [ 'mode', 'paste', 'filename', 'linter', ],
  \     ],
  \     'right': [
  \       [ 'gitbranch', ],
  \       [ 'lineinfo', 'percent', ],
  \       [ 'fileformat', 'filetype', ],
  \     ],
  \   },
  \   'component_function': {
  \     'gitbranch':  'FugitiveHead',
  \     'linter':     'LinterStatus',
  \     'filename':   'StatusFileName',
  \   },
  \ }

"
" fzf
"

" Command for git grep
" - fzf#vim#grep(command, with_column, [options], [fullscreen])
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number '.shellescape(<q-args>), 0,
  \   { 'dir': systemlist('git rev-parse --show-toplevel')[0] }, <bang>0)
noremap <S-F> :GGrep <C-R>=expand("<cword>")<return><return>

"
" vim-shortcut
"
runtime plugin/shortcut.vim

" at least execute map if vim-shortcut is not available
if !exists(':Shortcut')
  command! -bang -nargs=+ Shortcut call s:null_shortcut(<q-args>, <bang>0)

  function! s:null_shortcut_parse(input) abort
    let parts = split(a:input, '\s*\ze\<[nvxsoilct]\?\%(nore\)\?map\>')
    if len(parts) < 2
      throw 'expected "<description> <map-command>" but got ' . string(a:input)
    endif
    let [description; rest] = parts
    let definition = join(rest, '')
    return [description, definition]
  endfunction

  function! s:null_shortcut(qargs, bang) abort
    if !a:bang
      let [description, definition] = s:null_shortcut_parse(a:qargs)
      execute definition
    endif
  endfunction
endif

" vim-shortcut bindings
Shortcut show shortcut menu and run chosen shortcut
  \ noremap <silent> <leader><leader> :Shortcuts<return>
Shortcut fallback to shortcut menu on partial entry
  \ noremap <silent> <leader> :Shortcuts<return>
" fzf bindings
Shortcut Fuzzy search in files
  \ noremap <C-P> :GFiles<return>
Shortcut Fuzzy search in buffers
  \ noremap <leader>b :Buffers<return>
Shortcut Fuzzy search in history
  \ noremap <leader>h :History<return>
Shortcut Fuzzy search in commits (current buffer)
  \ noremap <leader>c :BCommits<return>
Shortcut Fuzzy search in commits
  \ noremap <leader>C :Commits<return>
Shortcut Fuzzy search in tags (current buffer)
  \ noremap <leader>t :BTags<return>
Shortcut Fuzzy search in tags
  \ noremap <leader>T :Tags<return>
Shortcut Fuzzy search in lines (current buffer)
  \ noremap <leader>l :BLines<return>
Shortcut Fuzzy search in lines
  \ noremap <leader>L :Lines<return>
Shortcut Fuzzy search in marks
  \ noremap <leader>' :Marks<return>
Shortcut Fuzzy git grep
  \ noremap <leader>g :GGrep<return>

Shortcut Explorer noremap <leader>E :Ex<return>
Shortcut Save buffer (force) noremap <leader>w :w!<return>
Shortcut Save buffer and exit (force) noremap <leader>x :x!<return>
Shortcut Quit noremap <leader>q :q<return>
Shortcut Close buffer noremap <leader>d :bd<return>
Shortcut Close buffer (force) noremap <leader>D :bd!<return>
Shortcut Explorer noremap <leader>E :Ex<return>
Shortcut Open new tab noremap <leader>N :tagnew<return>
Shortcut Toggler show numbers noremap <leader>n :set number!<return>
Shortcut Toggler tag/space mode (current buffer)
  \ noremap <leader>s :setl noexpandtab! <bar> setl shiftwidth=4 <bar> setl tabstop=4 <bar> setl softtabstop=4<return>

command! -bang -nargs=0 SourceLocal :source $MYVIMRC
command! -bang -nargs=0 SourceSystemWide :source /etc/vimrc
Shortcut! :SourceLocal<return> Reload $MYVIMRC (source)
Shortcut! :SourceSystemWide<return> Reload system-wide vimrc (source)

for i in range(1,9)
  execute 'Shortcut go to tab number '. i .' '
        \ 'noremap <silent> <leader>'. i .' :tabfirst<bar>'. i .'tabnext<return>'
endfor

" vim-tags
Shortcut! :TagsGenerate<return> Generate tags
Shortcut! :TagsGenerate!<return> Generate tags (force)

" taglist.vim
Shortcut! :TlistToggle<return> Toggle tags (current buffer)

" vim-fugitive
command! -bang -nargs=0 GBlame :Git blame
Shortcut! :GBlame<return> git blame
command! -bang -nargs=0 GAmend :Git commit --amend
Shortcut! :GAmend<return> git commit amend
" git conflict resolution
Shortcut! :Gdiff<return>            git diff
Shortcut! :Gvdiff<return>           git diff (vertical)
Shortcut! :Gdiff!<return>           git diff (3-way)
Shortcut! :Gvdiff!<return>          git diff (vertical, 3-way)
Shortcut Update diff noremap <leader>du :diffupdate<return>
" 2-way diff (cherry-pick)
Shortcut diffget noremap <leader>do :diffget<return>
Shortcut diffput noremap <leader>dP :diffput<return>
" 3-way diff (merge)
Shortcut diffget from target noremap <leader>dg :diffget //2<return>
Shortcut diffget from merge  noremap <leader>dG :diffget //3<return>


" Plug
Shortcut! :PlugInstall<return> Install plugins
Shortcut! :PlugUpdate<return>  Update plugins
Shortcut! :PlugUpdate!<return> Update plugins (force)
Shortcut! :PlugStatus<return>  Plugins status

" gundo
Shortcut! :GundoToggle<return> undo tree

" vimgist
"
" Do not forget to put "token XXX" into ~/.gist-vim
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1
let g:gist_per_page_limit = 100
command! -bang -nargs=0 PrivateGist :Gist -p
command! -bang -nargs=0 PublicGist :Gist -P
command! -bang -nargs=0 ListGist :Gist -l
Shortcut! :PrivateGist<return> Private gist
Shortcut! :PublicGist<return> Public gist
Shortcut! :ListGist<return> List gist
Shortcut! :'<,'>Gist<return> Selected gist

let g:cargo_makeprg_params = 'build'
au filetype cpp setlocal makeprg=nice\ -n100\ ninja\ -k0\ -C\ $(git\ rev-parse\ --show-toplevel)/.cmake
au filetype c setlocal makeprg=ninja\ -k0\ -C\ $(git\ rev-parse\ --show-toplevel)/.cmake
" make via vim-dispatch
" NOTE: :Make+makeprg over :Dispatch
" (see https://github.com/tpope/vim-dispatch/issues/41#issuecomment-20555488)
Shortcut [make] noremap <leader>m :Make!<return>
Shortcut [errors] noremap <leader>e :Copen<return>

"
" coc
"
set updatetime=300 " default 4s
" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif
" coc shortcuts
Shortcut! :CocDiagnostics<return> CoC diagnostics
Shortcut! :CocInfo<return> CoC info
Shortcut! :CocOpenLog<return> CoC logs
Shortcut! :CocCommand<space>yaml.selectSchema<return> YAML select schema
Shortcut! :CocCommand<space>clangd.ast<return> clangd AST
Shortcut Alternate file (header/module) noremap <leader>ja :CocCommand clangd.switchSourceHeader<return>
Shortcut Format noremap <C-k> <Plug>(coc-format)<return>
Shortcut Displays the doc noremap K :call ShowDocumentation()<return>
Shortcut FixIt noremap <leader>F <Plug>(coc-fix-current)<return>
" FIXME: by some reason via "Shortcuts" it does not work, apparently it goes
" to the next line before executing command!
noremap <leader>r <Plug>(coc-rename)
noremap <C-\> <Plug>(coc-definition)
noremap <leader>jc <Plug>(coc-references)
noremap <leader>jC <Plug>(coc-references-used)
noremap <leader>ji <Plug>(coc-implementation)
noremap <leader>jd <Plug>(coc-declaration)
noremap <leader>jt <Plug>(coc-type-definition)
noremap <silent> [g <Plug>(coc-diagnostic-prev)
noremap <silent> ]g <Plug>(coc-diagnostic-next)
" coc formats (reat all JSON as JSONC to support comments)
augroup JsonToJsonc
    autocmd! FileType json set filetype=jsonc
augroup END
let g:coc_filetype_map = {
  \ 'yaml.ansible': 'ansible',
  \ }
" coc helpers
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

if PlugLoaded('nvim-treesitter')
  " nvim-treesitter
  lua << EOF
  require'nvim-treesitter.configs'.setup {
    auto_install = true,
    highlight = {
      enable = true,
    },
  }

  vim.wo.foldmethod = 'expr'
  vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
EOF
else
  set foldmethod=syntax
  set foldenable!
  hi Folded ctermbg=5 " color scheme dark reset can't handle folded info
endif
set foldlevel=1000

set pastetoggle=<leader>p

"
" detectindent
"
let g:detectindent_preferred_indent=4
let g:detectindent_max_lines_to_analyse=1024
let g:detectindent_preferred_expandtab=1
let g:is_bash=1
" Default indent is with spaces
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
" Always Tab for Makefile
au FileType make set noexpandtab
au FileType make let detectindent_preferred_expandtab=0

"
" vim-todo-highlight
"
let g:todo_highlight_config = {
  \   'REVIEW': {},
  \   'NOTE': {
  \     'gui_fg_color': '#ffffff',
  \     'gui_bg_color': '#ffbd2a',
  \     'cterm_fg_color': 'white',
  \     'cterm_bg_color': '214'
  \   }
  \ }

"
" filetype plugin
"
filetype plugin on
filetype plugin indent on
autocmd BufEnter    * if &filetype == "" | setlocal ft=sh | endif
if PlugLoaded('detectindent')
  autocmd BufReadPost * :DetectIndent
endif

"
" bindings (other shortcut)
"
noremap  <F1> :setlocal spell!<return>
inoremap <F1> <C-\><C-O>:setlocal spell!<return>

nnoremap <C-a> <nop>
nnoremap <C-x> <nop>

" < & > - indent
vmap < <gv
vmap > >gv

" tab movements
map <C-left> :tabprev<return>
map <C-right> :tabnext<return>

" toggle *pointer*
noremap  <C-C>  :set cursorline! <bar> set cursorcolumn!<return>
inoremap <C-C>  <C-O>:set cursorline! <bar> set cursorcolumn!<return>
