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
" General notes
"-----------------------------------------------------------------------
"
" * Functions are defined with "function!" instead of "function" to help
"   keep this vimrc file idempotent. Without the "!", re-sourcing this
"   vimrc file would fail to overwrite the existing functions.
"

"-----------------------------------------------------------------------
" The vimrc autocommand group
"-----------------------------------------------------------------------
"
" We use an autocommand group named vimrc to hold our autocommands, and
" we initially clear it to help keep this vimrc file idempotent. If we
" didn't do this, re-sourcing this vimrc file would create duplicate
" autocommands.
"

augroup vimrc
  autocmd!
augroup end

"-----------------------------------------------------------------------
" Encoding
"-----------------------------------------------------------------------
"
" Note that the encoding option must be set before any use of Unicode in
" this vimrc file itself.
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
highlight MatchParen term=underline ctermbg=5

highlight NonText NONE
highlight! link NonText NONE
highlight NonText ctermfg=3

highlight Search NONE
highlight! link Search NONE
highlight link Search MatchParen

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

"-----------------------------------------------------------------------
" History
"-----------------------------------------------------------------------

set history=10000

set viminfo=
set viminfo+='0
set viminfo+=/100
set viminfo+=:100
set viminfo+=@0
set viminfo+=f0
set viminfo+=s10

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
      let l:x .= ':echo "Search highlighting: "'
      let l:x .= ' . "/" . getreg("/") . "/"' . "\n"
    else
      let l:x .= ':echo "Search highlighting: off"' . "\n"
    endif
  endif
  return l:x
endfunction

nnoremap <silent><expr> <C-h> ToggleSearchHighlightingExpr()
xnoremap <silent> <C-h> :<C-u>:let v:hlsearch = !v:hlsearch<CR>gv
inoremap <silent> <C-h> <C-o>:let v:hlsearch = !v:hlsearch<CR>

"-----------------------------------------------------------------------
" Automatic formatting
"-----------------------------------------------------------------------

autocmd vimrc BufEnter *
  \ setlocal formatoptions=nq

autocmd vimrc BufEnter *
  \ setlocal formatlistpat=\\v\\c^\\s*
                           \([*-]
                          \\|(0
                           \\|[1-9][0-9]?
                           \\|[a-z]
                           \\|x?x?(v?ii?i?\|i?[vx])
                            \)\\.
                          \\|todo:
                           \)\\s+

function! Gq(visual)
  const l:old_autoindent = &autoindent
  const l:old_expandtab = &expandtab
  try
    let &autoindent = 1
    let &expandtab = 1
    if a:visual
      normal! gv
    endif
    normal! gq
  finally
    let &autoindent = l:old_autoindent
    let &expandtab = l:old_expandtab
  endtry
endfunction

nnoremap <silent> gq :call Gq(0)<CR>
xnoremap <silent> gq <Esc>:call Gq(1)<CR>

"-----------------------------------------------------------------------
" Code formatting
"-----------------------------------------------------------------------
"
" :<C-u>call and all_lines are used instead of :<C-u>%call because the
" latter always moves the cursor to line 1 instead of leaving it alone.
"
" Note that the purpose of <C-u> is to remove any possible range that
" Vim automatically inserts when : is entered.
"

function! DoClangFormat(all_lines, clang_format) range

  let l:x = '%(\.m4)?%(\.im)?%(\.in)?$'

  let l:y = '\.%(c'
  let l:y = l:y . '|c'
  let l:y = l:y . '|cpp'
  let l:y = l:y . '|cs'
  let l:y = l:y . '|h'
  let l:y = l:y . '|hpp'
  let l:y = l:y . '|java'
  let l:y = l:y . '|js'
  let l:y = l:y . '|mjs'
  let l:y = l:y . ')' . l:x

  let l:f = @%

  if l:f =~ '\v' . l:y
    let l:f = substitute(l:f, '\v' . l:x, '', '')
    let l:f = substitute(l:f, '\v.*\.', 'x.', '')
    let l:clang_format_args = '--assume-filename=' . l:f
  else
    echo ''
    return
  endif

  if a:all_lines
    let l:first = 1
    let l:last = line('$')
  else
    let l:first = a:firstline
    let l:last = a:lastline
  endif

  let l:indent = getline(l:first)
  let l:indent = substitute(l:indent, '[^ 	].*', '', '')
  let l:indent = substitute(l:indent, '	', '        ', '')
  let l:indent = len(l:indent) / 2

  if l:indent > 0
    call append(l:last, repeat(['}'], l:indent))
    call append(l:first - 1, repeat(['if (x) {'], l:indent))
    let l:last += l:indent * 2
  endif

  if @% =~ '\v\.java\.m4'
    let l:do_m4_adjustment = 1
  else
    let l:do_m4_adjustment = 0
  endif

  let l:x = 'silent '
  let l:x .= l:first . ',' . l:last . '!'
  if l:do_m4_adjustment
    let l:x .= 'sed "s/\\\$\\([1-9]\\)/_\\1/g" | '
  endif
  let l:x .= a:clang_format . ' ' . l:clang_format_args
  if l:do_m4_adjustment
    let l:x .= ' | sed "s/_\\([1-9]\\)/\$\\1/g"'
  endif
  let l:x .= ' | tail -n +' . (l:indent + 1)
  let l:x .= repeat(' | sed \$d', l:indent)
  execute l:x

  echo 'ok'

endfunction

function! DoRustFormat(all_lines) range

  let l:f = @%

  if l:f !~ '\v\.rs$'
    echo ''
    return
  endif

  if !a:all_lines
    echo "Can't format Rust snippets"
    return
  endif

  let l:first = 1
  let l:last = line('$')

  let l:x = 'silent '
  let l:x .= l:first . ',' . l:last . '!'
  let l:x .= 'rustfmt '
  execute l:x

  echo 'ok'

endfunction

function! Format(all_lines) range

  redraw
  echo "Formatting..."

  if a:all_lines
    let l:range = ''
  else
    let l:range = a:firstline . ',' . a:lastline
  endif

  const l:curpos = getcurpos()

  " Make undo restore the cursor properly.
  normal! ix
  normal! "_x

  let l:formatted = 0

  if !l:formatted
    let l:x = l:range
    let l:x .= 'call DoClangFormat(' . a:all_lines
    let l:x .= ', "clang-format")'
    let l:x = substitute(execute(l:x), '\v.*\n', '', '')
    if l:x == 'ok'
      let l:formatted = 1
    elseif l:x != ''
      redraw
      echo l:x
      return
    endif
  endif

  if !l:formatted
    let l:x = l:range
    let l:x .= 'call DoRustFormat(' . a:all_lines . ')'
    let l:x = substitute(execute(l:x), '\v.*\n', '', '')
    if l:x == 'ok'
      let l:formatted = 1
    elseif l:x != ''
      redraw
      echo l:x
      return
    endif
  endif

  if l:formatted
    call setpos('.', l:curpos)
    redraw
    echo "Formatting...done"
    return
  endif

  if @% =~ '\v^[!#-&(-~]+$'
    let l:x = @%
  else
    let l:x = shellescape(@%)
  endif
  redraw
  echo "Formatting...unknown file type: " . l:x

endfunction

nnoremap <silent> <C-k> :<C-u>call Format(1)<CR>
xnoremap <silent> <C-k> :call Format(0)<CR>

"-----------------------------------------------------------------------
" Terminal windows
"-----------------------------------------------------------------------

set termwinscroll=100000

"-----------------------------------------------------------------------

autocmd vimrc FileType vim set comments=:\\"

"-----------------------------------------------------------------------
" Private vimrc file
"-----------------------------------------------------------------------

if filereadable(expand('~/.vimrc-private'))
  execute 'source' expand('~/.vimrc-private')
endif
