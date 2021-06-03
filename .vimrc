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
" Colors
"-----------------------------------------------------------------------

syntax off

highlight ColorColumn NONE
highlight ColorColumn term=reverse ctermbg=4

highlight IncSearch NONE
highlight IncSearch term=reverse ctermfg=0 ctermbg=3

highlight LineNr NONE
highlight link LineNr ColorColumn

highlight MatchParen NONE
highlight MatchParen term=reverse cterm=reverse

highlight NonText NONE
highlight NonText ctermfg=3

highlight Search NONE
highlight Search term=underline ctermbg=5

highlight SpecialKey NONE
highlight link SpecialKey NonText

highlight Visual NONE
highlight Visual term=reverse ctermbg=5

"-----------------------------------------------------------------------
" Search highlighting
"-----------------------------------------------------------------------

set hlsearch
set incsearch
nnoremap <silent> <C-h> :nohlsearch<CR>

"-----------------------------------------------------------------------
" Parenthesis matching
"-----------------------------------------------------------------------

set cpoptions+=M

set matchpairs=
set matchpairs+=(:)
set matchpairs+=<:>
set matchpairs+=[:]
set matchpairs+={:}

"-----------------------------------------------------------------------

set colorcolumn=73

set encoding=utf-8

set history=10000

set list

set listchars=
set listchars+=extends:┅
set listchars+=nbsp:▁
set listchars+=precedes:┅
set listchars+=tab:┣━╸
set listchars+=trail:╳

set nojoinspaces

set number

set textwidth=72

set viminfo=
set viminfo+='1000
set viminfo+=s1000

"-----------------------------------------------------------------------

function! GetClangFormatArgs()
  let l:suffix = []
  let l:suffix += ['c']
  let l:suffix += ['cpp']
  let l:suffix += ['cs']
  let l:suffix += ['h']
  let l:suffix += ['hpp']
  let l:suffix += ['java']
  let l:suffix += ['js']
  let l:suffix += map(copy(l:suffix), 'v:val . ".im"')
  let l:suffix += map(copy(l:suffix), 'v:val . ".in"')
  call map(l:suffix, '"%(" . v:val . ")"')
  let l:suffix = '\.(' . join(l:suffix, '|') . ')$'
  let l:name = @%
  if l:name =~ '\v' . l:suffix
    let l:name = substitute(l:name, '\v%(\.im)?%(\.in)?$', '', '')
    let l:name = substitute(l:name, '\v.*' . l:suffix, 'x.\1', '')
    return '--assume-filename=' . l:name
  endif
  return ''
endfunction

function! Reformat()

  let l:args = GetClangFormatArgs()
  if l:args != ''

    " Make undo restore the cursor properly.
    normal! ix
    normal! x

    let l:pos = getcurpos()
    execute 'silent %!clang-format ' . l:args
    call setpos('.', l:pos)

    return

  endif

endfunction

nnoremap <silent> <C-k> :call Reformat()<CR>

"-----------------------------------------------------------------------

aug vimrc
  au!
  au BufNewFile,BufRead,VimEnter * setl fo=q
aug END

autocmd FileType vim set comments=:\\"

"-----------------------------------------------------------------------

if filereadable(expand('~/.vimrc-private'))
  execute 'source' expand('~/.vimrc-private')
endif
