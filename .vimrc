"
" The authors of this file have waived all copyright and
" related or neighboring rights to the extent permitted by
" law as described by the CC0 1.0 Universal Public Domain
" Dedication. You should have received a copy of the full
" dedication along with this file, typically as a file
" named <CC0-1.0.txt>. If not, it may be available at
" <https://creativecommons.org/publicdomain/zero/1.0/>.
"

"-----------------------------------------------------------------------

augroup vimrc
  autocmd!
augroup END

"-----------------------------------------------------------------------
" Encoding
"-----------------------------------------------------------------------
"
" The encoding option must be set before any use of Unicode in this
" vimrc file itself.
"

set encoding=utf-8

"-----------------------------------------------------------------------
" Syntax highlighting
"-----------------------------------------------------------------------

syntax off

"-----------------------------------------------------------------------
" Highlight groups
"-----------------------------------------------------------------------

highlight ColorColumn NONE
highlight! link ColorColumn NONE
highlight ColorColumn term=reverse ctermbg=4

highlight CursorLineNr NONE
highlight! link CursorLineNr NONE
highlight CursorLineNr term=reverse,underline ctermbg=5

highlight IncSearch NONE
highlight! link IncSearch NONE
highlight IncSearch term=reverse ctermfg=0 ctermbg=3

highlight LineNr NONE
highlight! link LineNr NONE
highlight link LineNr ColorColumn

highlight MatchParen NONE
highlight! link MatchParen NONE
highlight MatchParen term=reverse cterm=reverse

highlight NonText NONE
highlight! link NonText NONE
highlight NonText ctermfg=3

highlight Search NONE
highlight! link Search NONE
highlight Search term=underline ctermbg=5

highlight SpecialKey NONE
highlight! link SpecialKey NONE
highlight link SpecialKey NonText

highlight StatusLine NONE
highlight! link StatusLine NONE
highlight StatusLine term=reverse,underline cterm=underline ctermbg=5

highlight StatusLineNC NONE
highlight! link StatusLineNC NONE
highlight StatusLineNC term=reverse cterm=underline ctermbg=4

highlight StatusLineTerm NONE
highlight! link StatusLineTerm NONE
highlight link StatusLineTerm StatusLine

highlight StatusLineTermNC NONE
highlight! link StatusLineTermNC NONE
highlight link StatusLineTermNC StatusLineNC

highlight TabLine NONE
highlight! link TabLine NONE
highlight link TabLine StatusLineNC

highlight TabLineFill NONE
highlight! link TabLineFill NONE
highlight link TabLineFill StatusLineNC

highlight TabLineSel NONE
highlight! link TabLineSel NONE
highlight link TabLineSel StatusLine

highlight VertSplit NONE
highlight! link VertSplit NONE
highlight VertSplit ctermfg=4 ctermbg=7

highlight Visual NONE
highlight! link Visual NONE
highlight link Visual IncSearch

"-----------------------------------------------------------------------

set colorcolumn=73

set cpoptions=aABceFMs

set fillchars=
set fillchars+=stl:\ 
set fillchars+=stlnc:\ 
set fillchars+=vert:▉

set history=10000

set list

set listchars=
set listchars+=extends:┅
set listchars+=nbsp:▁
set listchars+=precedes:┅
set listchars+=tab:┣━━
set listchars+=trail:▒

set matchpairs=
set matchpairs+=(:)
set matchpairs+=<:>
set matchpairs+=[:]
set matchpairs+={:}

set nojoinspaces

set textwidth=72

set viminfo=
set viminfo+='1000
set viminfo+=s1000

"-----------------------------------------------------------------------
" Line numbering
"-----------------------------------------------------------------------

set number
autocmd vimrc FileType help setlocal number

"-----------------------------------------------------------------------
" Cursor line highlighting
"-----------------------------------------------------------------------

set cursorline
set cursorlineopt=number

"-----------------------------------------------------------------------
" Search highlighting
"-----------------------------------------------------------------------

set hlsearch
set incsearch

function! ToggleSearchHighlightingExpr()
  let l:x = ''
  if &hlsearch
    let l:x .= ':let v:hlsearch = ' . !v:hlsearch . "\n"
    if !v:hlsearch
      let l:x .= ':echo "search highlighting: "'
      let l:x .= ' . "/" . getreg("/") . "/"' . "\n"
    else
      let l:x .= ':echo "search highlighting: off"' . "\n"
    endif
  endif
  return l:x
endfunction

nnoremap <silent><expr> <C-h> ToggleSearchHighlightingExpr()
xnoremap <silent> <C-h> :<C-u>:let v:hlsearch = !v:hlsearch<CR>gv
inoremap <silent> <C-h> <C-o>:let v:hlsearch = !v:hlsearch<CR>

"-----------------------------------------------------------------------

function! DoClangFormat(clang_format) range
  let l:xs = []
  let l:xs += ['c']
  let l:xs += ['cpp']
  let l:xs += ['cs']
  let l:xs += ['h']
  let l:xs += ['hpp']
  let l:xs += ['java']
  let l:xs += ['js']
  let l:xs += map(copy(l:xs), 'v:val . ".m4"')
  let l:xs += map(copy(l:xs), 'v:val . ".im"')
  let l:xs += map(copy(l:xs), 'v:val . ".in"')
  call map(l:xs, '"%(" . v:val . ")"')
  let l:xs = '\.(' . join(l:xs, '|') . ')$'
  let l:name = @%
  if l:name =~ '\v' . l:xs
    let l:name = substitute(l:name, '\v%(\.im)?%(\.in)?$', '', '')
    let l:name = substitute(l:name, '\v.*' . l:xs, 'x.\1', '')
    let l:clang_format_args = '--assume-filename=' . l:name
  else
    return
  endif

  " Make undo restore the cursor properly.
  normal! ix
  normal! x

  let l:indent = getline(a:firstline)
  let l:indent = substitute(l:indent, '[^ 	].*', '', '')

  if @% =~ '\v\.java\.m4'
    let l:do_m4_adjustment = 1
  else
    let l:do_m4_adjustment = 0
  endif

  let l:x = 'silent '
  let l:x .= a:firstline . ',' . a:lastline . '!'
  if l:do_m4_adjustment
    let l:x .= 'sed "s/\\\$\\([1-9]\\)/_\\1/g" | '
  endif
  let l:x .= a:clang_format . ' ' . l:clang_format_args
  if l:do_m4_adjustment
    let l:x .= ' | sed "s/_\\([1-9]\\)/\$\\1/g"'
  endif
  let l:x .= ' | sed "/./s/^/' . l:indent . '/"'
  execute l:x

  echo 'make sure the output is nonempty'
endfunction

function! Format() range

  redraw
  echo "formatting..."

  const l:curpos = getcurpos()

  let l:formatted = 0

  if !l:formatted
    let l:x = ':' . a:firstline . ',' . a:lastline
    let l:x .= 'call DoClangFormat("clang-format")'
    let l:x = execute(l:x, 'silent')
    if l:x != ''
      let l:formatted = 1
    endif
  endif

  if l:formatted
    call setpos('.', l:curpos)
    redraw
    echo "formatting...done"
    return
  endif

  if @% =~ '\v^[!#-&(-~]+$'
    let l:x = @%
  else
    let l:x = shellescape(@%)
  endif
  redraw
  echo "formatting...unknown file name: " . l:x

endfunction

nnoremap <silent> <C-k> :<C-u>%call Format()<CR>
xnoremap <silent> <C-k> :call Format()<CR>

"-----------------------------------------------------------------------

autocmd vimrc BufNewFile,BufRead,VimEnter * setl fo=q
autocmd vimrc FileType vim set comments=:\\"

"-----------------------------------------------------------------------
" Private vimrc file
"-----------------------------------------------------------------------

if filereadable(expand('~/.vimrc-private'))
  execute 'source' expand('~/.vimrc-private')
endif
