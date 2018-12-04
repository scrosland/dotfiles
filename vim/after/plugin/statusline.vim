function! s:gitroot()
  if !executable('git')
    return ''
  endif
  " fugitive might have already detected a git dir
  let l:root = substitute(get(b:, 'git_dir', ''), '/.git$', '', '')
  return fnamemodify(l:root, ':t')
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
