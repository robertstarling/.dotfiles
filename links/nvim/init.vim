" Notes on vimscript style:
"
" Typically, vimscript (and blankspace) should be Pythonic.
"
" In general, use plugin-names-like-this, FunctionNamesLikeThis,
" CommandNamesLikeThis, augroup_names_like_this, variable_names_like_this.
"
"===[ Helper functions
function IsGitRepo()
  silent let root = system('git rev-parse')
  return !v:shell_error
endfunction

"===[ Plugins
call plug#begin('~/.config/nvim/plugged')

" Colorschemes
Plug 'romainl/Apprentice'

" Things that should be built in
Plug 'tpope/vim-surround'
" This isn't working with vim-go
" Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'wellle/targets.vim'
Plug 'wellle/context.vim'

" Git
Plug 'tpope/vim-fugitive'
nnoremap <silent> <space>gst :Gstatus<CR>
nnoremap <silent> <space>glo :Glog -10<CR>
nnoremap <silent> <space>gdi :Gvdiff<CR>
nnoremap <silent> <space>gad :Gwrite<CR>
nnoremap <silent> <space>gre :Gread<CR>
nnoremap <silent> <space>gco :Gcommit<CR>
nnoremap <silent> <space>ged :Gedit<CR>




Plug 'airblade/vim-gitgutter'

" Assorted
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Prefix all of the fzf commands to make them easier to 'browse'
let g:fzf_command_prefix = "Fzf"
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" TODO: I don't know who wrote this*, but it's psychotic. Please fix it.
" *it was me, I wrote it
let git_source = 'bash -c '.shellescape('comm -3 <(git ls-files --other --exclude-standard --cached | sort) <(git ls-files --deleted --exclude-standard | sort)')
let file_source = 'fd . --type f --type l'
let all_source = file_source . ' --hidden --no-ignore'
if IsGitRepo()
  " This is madness...
  " The comm command will list all the files tracked by git, excluding any deleted files.
  " However, fzf insists on using sh rather than bash, and the 'command <(other_command)' syntax (Process Substitution)
  " is not POSIX compliant, and doesn't work in sh. So this command will tell sh to run the 'comm' command using bash
  let fzf_source = git_source
else
  let fzf_source = file_source
endif

" So this is smart - f* will use git files if in a git repo, and fd files otherwise
nnoremap <silent> <space>ff :call fzf#run(fzf#wrap({'source': fzf_source, 'sink': 'edit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>fv :call fzf#run(fzf#wrap({'source': fzf_source, 'sink': 'vsplit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>fs :call fzf#run(fzf#wrap({'source': fzf_source, 'sink': 'split', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>

nnoremap <silent> <space>FF :call fzf#run(fzf#wrap({'source': all_source, 'sink': 'edit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>FV :call fzf#run(fzf#wrap({'source': all_source, 'sink': 'vsplit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>FS :call fzf#run(fzf#wrap({'source': all_source, 'sink': 'split', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>

" Shortcut to find buffers
nnoremap <silent> <space>bb :call fzf#run(fzf#wrap({'source': map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'), 'sink': 'edit', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>bs :call fzf#run(fzf#wrap({'source': map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'), 'sink': 'sbuffer', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>
nnoremap <silent> <space>bv :call fzf#run(fzf#wrap({'source': map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'), 'sink': 'vert sbuffer', 'window': {'width': 0.9, 'height': 0.6}, 'options': ['--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}))<cr>

" Git shortcuts
nnoremap <space>gcc :FzfCommits<cr>
nnoremap <space>gcb :FzfBCommits<cr>
nnoremap <space><space>gst :call fzf#vim#gitfiles('?')<cr>

" Search/history shortcuts
nnoremap <space><space>/ :FzfAg<cr>
nnoremap q: :call fzf#vim#command_history()<cr>
nnoremap q/ :call fzf#vim#search_history()<cr>

" assorted shortcuts
nnoremap <space>ll :FzfLines<cr>
nnoremap <space>lb :FzfBLines<cr>
nnoremap <space>: :FzfCommands<cr>

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)





Plug 'jabirali/vim-tmux-yank'

Plug 'christoomey/vim-tmux-navigator'
nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
nnoremap <silent> <c-\> :TmuxNavigatePrevious<cr>


Plug 'skywind3000/asyncrun.vim'
" Fast access to asyncronous background jobs
nnoremap <space>! :AsyncRun<space>
nnoremap <space>/ :AsyncRun! -post=botright\ copen -program=grep --ignore-dir "vendor"<space>
nnoremap <space>* :AsyncRun! -post=botright\ copen -program=grep --ignore-dir "vendor" <cword> -ws<CR>







Plug 'dense-analysis/ale'
"Always show the gutter
let g:ale_sign_column_always = 1

"Stop linting 'on the fly' in insert mode
let g:ale_lint_on_text_changed = 'normal'
"I'd rather lint when we leave insert mode
let g:ale_lint_on_insert_leave = 1

"Custom signs for gutter
" TODO: Figure these out
" let g:ale_sign_error = "❌"
" let g:ale_sign_warning = "⚠️"
" let g:ale_sign_info = "ℹ️"
let g:ale_sign_error = "✗"
let g:ale_sign_warning = "∆"
let g:ale_sign_info = "ⅰ"

highlight ALEErrorSign ctermfg=red
highlight ALEWarningSign ctermfg=yellow
highlight ALEInfoSign ctermfg=cyan

" Show popups on hover
let g:ale_floating_preview = 1
" Since vim's default uses nice unicode characters when possible, you can trick
" ale into using that default with
let g:ale_floating_window_border = repeat([''], 6)

set omnifunc=ale#completion#OmniFunc

let g:ale_linters = {
      \ 'go': [
        \ 'golangci-lint',
        \ 'go build',
        \ 'gopls',
        \],
      \}

" I don't really care to lint yaml
let g:ale_linters_ignore = {'yaml': ['yamllint']}

" Turn linting errors into warnings
let g:ale_type_map = {
      \ 'flake8': {'ES': 'WS', 'E': 'W'},
      \ 'golangci-lint': {'ES': 'WS', 'E': 'W'},
      \}

" let ale know that we're using python3
let g:ale_python_flake8_executable = 'python3'
let g:ale_python_flake8_options = '-m flake8'

let g:ale_go_golangci_lint_package = 1
let g:ale_go_golangci_lint_options = '--config ~/.golangci.yaml'

let g:ale_sh_shellcheck_exclusions = 'SC1090'




Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
let g:go_fmt_fail_silently = 1

" I need to revisit whether I need vim-qf anymore now that cfilter exists, but I have a retro in 5 minutes, so
" that'll be future Ian's problem
Plug 'romainl/vim-qf'
packadd cfilter
nnoremap <space>q/ :Cfilter //<Left>
nnoremap <space>q! :Cfilter! //<Left>
nnoremap <space>qx :Cfilter! /mock\\|test/<cr>

nnoremap - z20<cr>

Plug 'github/copilot.vim'
" The following 2 lines need to stay together; Combinded, they replace 'Tab' with <c-e> to accept a suggestion
imap <silent><script><expr> <C-E> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

imap <C-J> <Plug>(copilot-next)
imap <C-K> <Plug>(copilot-previous)
imap <C-L> <Plug>(copilot-accept-word)

" Enable copilot for all filetypes
let b:copilot_enabled = v:true

call plug#end()

"For more matching. See :h matchit
runtime macros/matchit.vim

"===[ Colors
syntax enable

function! ApprenticeOverrides() abort
    hi DiffAdd ctermbg=238 ctermfg=NONE cterm=NONE guibg=#444444 guifg=NONE gui=NONE
    hi DiffChange ctermbg=250 ctermfg=238 cterm=reverse guibg=#bcbcbc guifg=#444444 gui=reverse
    hi DiffDelete ctermbg=52 ctermfg=52 cterm=NONE guibg=#5f0000 guifg=NONE gui=NONE
    hi DiffText ctermbg=235 ctermfg=110 cterm=reverse guibg=#262626 guifg=#8fafd7 gui=reverse
endfunction

augroup apprentice_overrides
    autocmd!
    autocmd ColorScheme apprentice call ApprenticeOverrides()
augroup END

" This is such a hack: set the colorscheme to torte, then set it to apprentice.
" If setting it to apprentice fails, it will do so quietly. This is important
" when installing plugins with 'vim +PlugInstall +qall'
colorscheme torte
silent! colorscheme apprentice

"Show all non-printable characters (ascii index <= 32)
highlight NonPrintableCharacters ctermfg=208 ctermbg=208 cterm=NONE
augroup emphasize_non_printable_characters
  autocmd BufEnter * match NonPrintableCharacters /\b(3[0-1]|[0-2]?[0-9])\b/
augroup END

"===[ Search behaviour
set incsearch                        "Lookahead as search pattern is specified

" TODO: I think I want to delete this
"Pulled from :help 'incsearch' - highlight all matches while searching
augroup vimrc_incsearch_highlight
    autocmd!
    autocmd CmdlineEnter /,\? :set hlsearch
    autocmd CmdlineLeave /,\? :set nohlsearch
augroup END

nnoremap <space>hl :set hlsearch! hlsearch?<cr>

" Defines an operator that will search for the specified text.
function SetSearch( type )
  let saveZ = @z

  if a:type == 'line'
    '[,']yank z
  elseif a:type == 'block'
    " This is not likely as it can only happen from visual mode, for which the mapping isn't defined anyway
    execute "normal! `[\<c-v>`]\"zy"
  else
    normal! `[v`]"zy
  endif

  " Escape out special characters as well as convert spaces so more than one can be matched.
  let value = substitute( escape( @z, '$*^[]~\/.' ), '\_s\+', '\\_s\\+', 'g' )

  let @/ = value
  let @z = saveZ

  " Add it to the search history.
  call histadd( '/', value )

  set hls
endfunction
nnoremap ,/ :set opfunc=SetSearch<cr>g@

"===[ Tab behaviour
set shiftwidth=4       "Indent/outdent by 4 columns
set shiftround         "Indents always land on a multiple of shiftwidth
set smarttab           "Backspace deletes a shiftwidth's worth of spaces
set expandtab          "Turns tabs into spaces
set autoindent         "Keep the same indentation level when inserting a new line

"===[ Line and column display settings
"== Lines =="
set nowrap             "Don't word wrap
set breakindent        "However, if I *do* turn on wrap, I'd like to keep the same level of indentation
set number             "Show the cursor's current line

"Highlight the current line, column, and the 80th column
setlocal cursorline
setlocal cursorcolumn
setlocal colorcolumn=80
hi CursorLine ctermbg=236
hi CursorColumn ctermbg=236

" Background colors for active vs inactive windows
" Note that "black" means the same as "transparent"
" TODO: notermguicolors is fine for now, but it's probably pretty limiting...
set notermguicolors
hi link ActiveWindow Normal
hi InactiveWindow ctermbg=black

" Change highlight group of active/inactive windows
function HandleFocusEnter()
  setlocal cursorline
  setlocal cursorcolumn
  setlocal colorcolumn=80
  setlocal winhighlight=Normal:ActiveWindow,NormalNC:InactiveWindow
endfunction

" Change highlight group of active/inactive windows
function HandleFocusLeave()
  setlocal nocursorline
  setlocal nocursorcolumn
  setlocal colorcolumn=
  setlocal winhighlight=Normal:InactiveWindow,NormalNC:InactiveWindow
endfunction

"Only highlight the active window
augroup highlight_follows_focus
  autocmd!
  autocmd WinEnter,FocusGained * call HandleFocusEnter()
  autocmd WinLeave,FocusLost * call HandleFocusLeave()
augroup END


"== Columns =="
" sidescroll has some sort of issue with ALE, in which a line with an error or warning fails to render when
" scrolling. I'm leaving it commented out here so I don't accidentally turn it back on in the future
" set sidescroll=1            "Set horizontal scroll speed
set textwidth=80            "gq will wrap text at 80, same as colorcolumn
set formatoptions=cqlMj     "In order: wrap comments automatically, allow 'gq' to work on comments,
                            "don't break long lines in insert mode, don't insert space when 'J'oining,
                            "remove comment leaders when 'J'oining lines
set signcolumn=yes          "Keep the sign column open at all times
set nostartofline           "Prevent the cursor fom changing columns when jumping

"===[ Windows and splitting
set splitright       "Put vertical splits on the right rather than the left
set splitbelow       "Put horizontal splits on the bottom rather than the top

" Zoom in on a specific window, tmux-style
nnoremap <c-w>z ma:tabedit %<cr>`a

"===[ Miscellaneous key mappings
"Quickly source vimrc
nnoremap <silent> <space>s :source $MYVIMRC<CR>

"Turn off the help on F1. The first is for normal-ish modes, while the second
"is for insert-ish modes
noremap <f1> <nop>
noremap! <f1> <nop>

"Fast bracketing (repeatable)
inoremap {{ {<CR>}<UP><END>
inoremap (( (<CR>)<UP><END>
inoremap [[ [<CR>]<UP><END>

"Yank to EOL like it should
nnoremap Y y$

"Easier access to system clipboard (highly opinionated)
map <space>' "+
"Since the above seems to be so flaky and system-dependent, here's another quick trick for pasting
nnoremap <silent> <space>pp :set paste<CR>i
"But I don't want to get stuck in paste mode; that's annoying
autocmd InsertLeave * set nopaste

"Remove all trailing blankspaces from a file
function StripTrailingBlankSpaces()
  let l:winview = winsaveview()
  silent! %s/\(\s\|\)\+$//e
  call winrestview(l:winview)
endfunction
nnoremap <silent> <space>ws :call StripTrailingBlankSpaces()<CR>
"Remove all non-printable characters from a file
nnoremap  <space>np :%s/[^!-~ \n\t]//g<CR>

"Sane paragraph boundaries
"TODO: Decide if this is necessary
function NextParagraph()
  let myline = search('^\s*$', 'W')
  if myline <= 0
    execute 'normal! G$'
  else
    execute 'normal! '.myline.'G0'
  endif
endfunction

function PrevParagraph()
  let myline = search('^\s*$', 'bW')
  if myline <= 0
    execute 'normal! gg0'
  else
    execute 'normal! '.myline.'G0'
  endif
endfunction
nnoremap <silent> { :<C-u>call PrevParagraph()<CR>
nnoremap <silent> } :<C-u>call NextParagraph()<CR>
xnoremap <silent> { :<C-u>exe "normal! gv"<Bar>call PrevParagraph()<CR>
xnoremap <silent> } :<C-u>exe "normal! gv"<Bar>call NextParagraph()<CR>

" Jump between function definitions. Taken from :help section
map [[ ?{<CR>w99[{
map ][ /}<CR>b99]}
map ]] j0[[%/{<CR>
map [] k$][%?}<CR>

"Make sure the mouse is off, even in gui environments
set mouse=
"Mappings to make the scrollwheel work as expected
noremap <ScrollWheelUp> 2<C-Y>
noremap <ScrollWheelDown> 2<C-E>
noremap <C-ScrollWheelUp> 5zh
noremap <C-ScrollWheelDown> 5zl
"Unmap all the useless mouse actions
noremap <LeftMouse> <nop>
noremap <RightMouse> <nop>
"but we can use this for convenient window swapping
noremap <C-LeftMouse> <LeftMouse>

"select newly pasted text
nnoremap gV `[v`]

"omg I hate Ex mode
nnoremap Q <nop>

"on the note of annoying things...
inoremap :w<cr> <esc>:w<cr>
inoremap :wq<cr> <esc>:wq<cr>
inoremap :W<cr> <esc>:w<cr>
inoremap :Wq<cr> <esc>:wq<cr>
inoremap :WQ<cr> <esc>:wq<cr>

"insert a seperator line
nnoremap <space>= 80i=<esc>


"===[ Statusline

"Custom modified flag
function FileModified()
  if &modified
    return "  ∆ "
  elseif !&modifiable
    return "  ✗ "
  else
    return "    "
  endif
endfunction

" TODO: This isn't used, but it's kinda neat. Let's work it in somehow
"Custom git branch flag
function GitBranch()
  if !IsGitRepo() || !&modifiable
    return ""
  endif
  let branch = FugitiveHead()
  if len(branch)
    return " «" . branch . "»"
  endif
  return " «detached HEAD»"
endfunction

"Always show the status line
set laststatus=2

set statusline=                            "Start empty
set statusline+=%{FileModified()}   "Mark whether the file is modified, unmodified, or unmodifiable
set statusline+=\ ‹%f›                     "File name
set statusline+=%=                         "Switch to the right side
set statusline+=\ L%l                      "Current line
set statusline+=\ C%c                      "Current column
set statusline+=\ %P                       "Percentage through file
set statusline+=\ %y                       "Filetype

"Finally, turn off the titlebar
set notitle

"===[ Fix misspellings on the fly
iabbrev          retrun           return
iabbrev           pritn           print
iabbrev           Pritn           Print
iabbrev         Pritnln           Println
iabbrev         printf9           printf(
iabbrev        fprintf9           fprintf(
iabbrev         Printf9           Printf(
iabbrev        Fprintf9           Fprintf(
iabbrev         incldue           include
iabbrev         inculde           include
iabbrev         inlcude           include
iabbrev              ;t           't
iabbrev            ymal           yaml

command! W w
command! Q q
command! QA qa
command! Qa qa
command! W w
command! WQ wq
command! Wq wq
command! WQa wqa
command! Wqa wqa

"===[ Folds
set foldmethod=syntax            "Create folds on syntax
set foldlevel=999                "Start vim with all folds open

"===[ Show undesirable hidden characters
"Show hidden characters
if &modifiable
  set list
endif

set listchars=tab:\ \ ,trail:·

let g:my_listchars_toggle = 0
function ToggleIndentationLines()
  if g:my_listchars_toggle == 1
    set listchars=tab:\ \ ,trail:·
  else
    "Set tabs to a straight line followed by blanks and trailing spaces to dots
    set listchars=tab:│\ ,trail:·
  endif
  let g:my_listchars_toggle = !g:my_listchars_toggle
endfunction
command TIL call ToggleIndentationLines()

"Remove the background highlighting from the above special characters
highlight clear SpecialKey

"===[ Tags
set tags=./tags;,tags;
nnoremap <space>tj :tjump /
nnoremap <space>tp :ptjump /

"===[ Persistant Undos
set undofile
" TODO: fix this
set undodir=$HOME/.vim/undo

"===[ File navigation
"Allow changed buffers to be hidden
set hidden

"Recursively search current directory
set path=.,,**

nnoremap <silent> <space>bn :bnext<cr>
nnoremap <silent> <space>bp :bprevious<cr>
nnoremap <silent> <space>bf :bfirst<cr>
nnoremap <silent> <space>bl :blast<cr>

"This does bufdo e without losing highlighting
"TODO: This is slow af. Use asyncrun
"TODO: actually, we're using neovim now. We probably don't need this at all
function EditWithoutLosingSyntax()
    let this_buffer = bufnr("%")
    bufdo set eventignore= | if &buftype != "nofile" && expand("%") != '' | edit | endif
    execute "b" . this_buffer
endfunction
nnoremap <silent> <space>be :call EditWithoutLosingSyntax()<cr>

augroup recall_position
  autocmd!
  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid, when inside an event handler
  " (happens when dropping a file on gvim) and for a commit message (it's
  " likely a different one than last time).
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\""
    \ | endif
augroup END

"===[ Grep customization
if executable('ag')
  let &grepprg='ag'
endif

"===[ Quickfix and Location window Shortcuts
nmap <space>qn <Plug>(qf_qf_next)
nmap <space>qp <Plug>(qf_qf_previous)
nmap <space>qq <Plug>(qf_qf_switch)

" This doesn't quite work the way I like it
" nmap <space>qt <Plug>(qf_qf_toggle)
" Use my own instead
" TODO: I think this can be simplified? Look into getqflist()
function ToggleQuickfix()
  for i in range(1, winnr('$'))
    let bnum = winbufnr(i)
    if getbufvar(bnum, '&buftype') == 'quickfix'
      cclose
      return
    endif
  endfor
  botright copen
endfunction
nmap <silent> <space>qt :call ToggleQuickfix()<cr>

" Quickly close all quickfix and location lists
" TODO: I think this might be overkill?
function Pclose()
  for i in range(1, winnr('$'))
    let bnum = winbufnr(i)
    if getbufvar(bnum, '&buftype') == 'nofile'
      execute "bdelete" . bnum
    endif
  endfor
endfunction
nmap <silent> <space>qc :windo lclose \| cclose \| call Pclose()<cr>

nmap <space>ln <Plug>(qf_loc_next)
nmap <space>lp <Plug>(qf_loc_previous)
nmap <space>lq <Plug>(qf_loc_switch)
nmap <space>lt <Plug>(qf_loc_toggle)

"The following setting provides these commands from the quickfix and location windows
" s - open entry in a new horizontal window
" v - open entry in a new vertical window
" t - open entry in a new tab
" o - open entry and come back
" O - open entry and close the location/quickfix window
" p - open entry in a preview window
let g:qf_mapping_ack_style = 1

let g:qf_auto_open_quickfix = 0

"===[ Wildmenu
set wildmenu
set wildmode=longest:full,full
set wildoptions=fuzzy,pum
set wildignore+=*.o,*.so
set wildignore+=*.d
set wildignore+=*.aux,*.out,*.pdf
set wildignore+=*.pyc,__pycache__
set wildignore+=*.tar,*.gz,*.zip,*.bzip,*.bz2
set wildignore+=tags
set wildignore+=/home/**/*venv*/**
set wildignore+=*.class
set wildignore+=*.png,*.jpg,*.bmp,*.gif
set wildignore+=*.html  " Comment this out for html, obviously
set wildignore+=*.doctree
set wildignore+=%*

"===[ Diffs
set diffopt+=algorithm:histogram,indent-heuristic

"Remove the dashes from DiffDelete. Mind the trailing space
set fillchars+=diff:\

"Mappings for working with diffs in visual mode
xnoremap <silent> <space>do :diffget<CR>
xnoremap <silent> <space>dp :diffput<CR>

"===[ Unsorted
"Sane backspace
set backspace=indent,eol,start
"Don't use swp files
set noswapfile
"Get out of visual mode faster
set ttimeoutlen=0
" Update faster. This is used for a handful of plugins (like git-gutter)
set updatetime=750
" Only redraw the screen when needed - this works for macros and mappings
set lazyredraw
" Sharing is caring - romainl: https://gist.github.com/romainl/1cad2606f7b00088dda3bb511af50d53
command! -range=% IX  <line1>,<line2>w !curl -F 'f:1=<-' ix.io | tr -d '\n' | xclip -i -selection clipboard
" Clipboard hacks - By default, vim clears out the system and X clipboards
" upon closing. This fixes that
augroup clipboard_retention
  autocmd!
  autocmd VimLeave * call system("xclip -i -selection primary", getreg('*'))
  autocmd VimLeave * call system("xclip -i -selection clipboard", getreg('+'))
augroup END
" Allow tons of tabs. This is useful for git-vimdiff
set tabpagemax=99

" Popup the latest git commit for the current line
nmap <silent><space>gbl :call setbufvar(winbufnr(popup_atcursor(split(system("git log -n 1 -L " . line(".") . ",+1:" . expand("%:p")), "\n"), { "padding": [1,1,1,1], "pos": "botleft", "wrap": 0 })), "&filetype", "git")<CR>

" TODO: This is a vim setting - figure out the neovim equivalent
" set completeopt=menu,menuone,popup

" Don't mess with the EOL characters at the end of a file
set nofixendofline
