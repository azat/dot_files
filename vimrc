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

"
" Plugins
"
function! BuildYCM(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
    !./install.py --clangd-completer --rust-completer --go-completer
  endif
endfunction

" for YouCompleteMe
let g:plug_timeout=600

call plug#begin('~/.vim/bundle')
Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
Plug 'w0rp/ale'
Plug 'junegunn/fzf' " dependency of fzf.vim
Plug 'junegunn/fzf.vim'
Plug 'sunaku/vim-shortcut'
Plug 'szw/vim-tags'
Plug 'vim-scripts/taglist.vim'
Plug 'ciaranm/detectindent'
Plug 'godlygeek/tabular'
Plug 'elzr/vim-json'
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
Plug 'terryma/vim-multiple-cursors'
Plug 'sakshamgupta05/vim-todo-highlight'
Plug 'mattn/webapi-vim'
Plug 'mattn/vim-gist'
Plug 'crusoexia/vim-monokai'
" Plug 'ericbn/vim-solarized'
Plug 'hashivim/vim-terraform'
Plug 'tmhedberg/SimpylFold' " fold for python
Plug 'rust-lang/rust.vim'
Plug 'pedrohdz/vim-yaml-folds'
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
syntax enable
try
  colorscheme monokai
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

" fold
set foldmethod=syntax
set foldenable!
set foldlevel=1000
hi Folded ctermbg=5 " color scheme dark reset can't handle folded info

"
" ale
"
let g:ale_lint_on_text_changed = 'never'
let g:ale_fixers = {
  \ '*':      [ 'trim_whitespace', ],
  \ 'python': [ 'autopep8', 'isort', ],
  \ }
let g:ale_linters = {
  \ 'cpp':    [],
  \ 'c':      [],
  \ }

"
" vim-tags
"
let g:vim_tags_directories = [ ".git/.." ]
let g:vim_tags_auto_generate = 0
let g:vim_tags_project_tags_command = "flock -n /tmp/vim-ctags.lock {CTAGS} -R {OPTIONS} {DIRECTORY} 2>/dev/null"

"
" lightline
"
function! ALEStatus() abort
  let l:counts = ale#statusline#Count(bufnr(''))

  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors

  return l:counts.total == 0 ? 'ALE: OK' : printf(
  \   'ALE: %dW %dE',
  \   all_non_errors,
  \   all_errors
  \)
endfunction
function! YCMStatus() abort
  let l:warnings = youcompleteme#GetWarningCount()
  let l:errors   = youcompleteme#GetErrorCount()
  let l:total    = warnings + errors

  return total == 0 ? 'YCM: OK' : printf(
  \   'YCM: %dW %dE',
  \   warnings,
  \   errors
  \)
endfunction
function! LinterStatus() abort
  let l:ale_enabled = exists('b:ale_linted')
  if ale_enabled
    return ALEStatus()
  else
    return YCMStatus()
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

" ale
Shortcut! :ALELint<return> Run ALE linters
Shortcut! :ALEInfo<return> Show ALE info (current buffer)
Shortcut! :ALEDetail<return> Show ALE details
Shortcut! :ALEFix<return> Run ALE fixers
Shortcut! :ALEFixSuggest<return> Show ALE suggest fixes
Shortcut! :ALEDisable<return> Disable ALE
Shortcut! :ALEEnable<return> Enable ALE
Shortcut! :ALEToggle<return> Toggle ALE

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

" ycm/YouCompleteMe
let g:ycm_always_populate_location_list=1
let g:ycm_auto_trigger=1
" Let clangd fully control code completion -- works faster
let g:ycm_clangd_uses_ycmd_caching = 0
" Use installed clangd, not YCM-bundled clangd which doesn't get updates that
" frequently.
let g:ycm_clangd_binary_path = exepath("clangd")
let g:ycm_rust_toolchain_root = fnamemodify(exepath("rust-analyzer"), ":p:h:h")
let g:ycm_auto_hover=''
" Only explicitly via <leader>gD/gd (to preview from the right, not from the
" botton)
set completeopt-=preview
" Preview from the right and adjust the width
command -count YcmShowDocWithSize
  \ let g:ph=&previewheight
  \ <bar> set previewheight=<count>
  \ <bar> <mods> YcmCompleter GetDoc
  \ <bar> let &previewheight=g:ph
command -count YcmShowDocImpreciseWithSize
  \ let g:ph=&previewheight
  \ <bar> set previewheight=<count>
  \ <bar> <mods> YcmCompleter GetDocImprecise
  \ <bar> let &previewheight=g:ph
Shortcut! :YcmRestartServer<return> YcmRestartServer
Shortcut! :YcmForceCompileAndDiagnostics<return> YcmForceCompileAndDiagnostics
Shortcut! :YcmDiags<return> YcmDiags
Shortcut! :YcmShowDetailedDiagnostic<return> YcmShowDetailedDiagnostic
Shortcut! :YcmDebugInfo<return> YcmDebugInfo
Shortcut! :YcmToggleLogs<return> YcmToggleLogs
" GoTo
Shortcut [ycm GoTo] GoTo (force)
  \ noremap <leader>jt :YcmCompleter GoTo<return>
Shortcut [ycm GoTo] GoTo
  \ noremap <C-\> :YcmCompleter GoTo<return>
Shortcut [ycm GoToInclude] Looks up the current line for a header and jumps to it
  \ noremap <leader>jI :YcmCompleter GoToInclude<return>
Shortcut [ycm GoToDeclaration] Looks up the symbol under the cursor and jumps to its declaration
  \ noremap <leader>jd :YcmCompleter GoToDeclaration<return>
Shortcut [ycm GoToDefinition] Looks up the symbol under the cursor and jumps to its definition
  \ noremap <leader>jD :YcmCompleter GoToDefinition<return>
Shortcut [ycm GoToCallers]
  \ noremap <leader>jc :YcmCompleter GoToCallers<return>
Shortcut [ycm GoToCallees]
  \ noremap <leader>jC :YcmCompleter GoToCallees<return>
Shortcut [ycm GoToAlternateFile (header/module)]
  \ noremap <leader>ja :YcmCompleter GoToAlternateFile<return>
" Semantic Information Commands
Shortcut [ycm GetType] Echos the type of the variable or method under the cursor
  \ noremap <leader>gT :YcmCompleter GetType<return>
Shortcut [ycm GetTypeImprecise] Echos the type of the variable or method under the cursor (force)
  \ noremap <leader>gt :YcmCompleter GetTypeImprecise<return>
Shortcut [ycm GetParent] Echos the semantic parent of the point under the cursor
  \ noremap <leader>gp :YcmCompleter GetParent<return>
Shortcut [ycm GetDoc] Displays the doc (force)
  \ noremap <leader>gd :rightbelow vertical 80YcmShowDocWithSize<return>
Shortcut [ycm GetDocImprecise] Displays the doc
  \ noremap <leader>gD :rightbelow vertical 80YcmShowDocImpreciseWithSize<return>
Shortcut [ycm] FixIt
  \ noremap <leader>F :YcmCompleter FixIt<return>
Shortcut [ycm] Rename
  \ noremap <leader>r :exe 'YcmCompleter RefactorRename '.input('refactor \"'.expand('<cword>').'\" to:')<return>

" TODO: make shortcuts works from menu and not only via <leader>

" syntax
command! -bang -nargs=0 ShowSyntaxList :syntax list
Shortcut! :ShowSyntaxList<return> Show syntax list
set synmaxcol=256

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

" clang-format
if has('python')
  map <C-K> :pyf /usr/share/clang/clang-format.py<return>
  imap <C-K> <c-o>:pyf /usr/share/clang/clang-format.py<return>
  Shortcut clang-format
    \ noremap <leader>k :pyf /usr/share/clang/clang-format.py<return>
elseif has('python3')
  map <C-K> :py3f /usr/share/clang/clang-format.py<return>
  imap <C-K> <c-o>:py3f /usr/share/clang/clang-format.py<return>
  Shortcut clang-format
    \ noremap <leader>k :py3f /usr/share/clang/clang-format.py<return>
endif
