function! s:gitroot()
  if !executable('git')
    return ''
  endif
  " fugitive should have already detected a git dir
  let l:root = substitute(FugitiveGitDir(), '/.git$', '', '')
  let l:branch = FugitiveHead()
  if l:branch == 'master'
    let l:branch = ''
  else
    let l:branch = '[' . l:branch . ']'
  endif
  return fnamemodify(l:root, ':t') . l:branch
endfunction

" Add external callbacks
for fn in [
      \ 's:gitroot',
      \ 'WrapDescribeForStatusLine',
      \ ]
  if exists('*'.fn)
    call StatusLineRegisterSectionBCallback(function(fn))
  else
    echomsg 'No such callback: ' . string(fn)
  endif
endfor
