function! s:gitroot()
  " fugitive might have already detected a git dir
  let l:root = substitute(get(b:, 'git_dir', ''), '/.git$', '', '')
  if empty(l:root)
    try
      " gitignore can find a git repo root directory
      let l:root = gitignore#git#root()
    catch
    endtry
  endif
  if empty(l:root)
    return ''
  endif
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
