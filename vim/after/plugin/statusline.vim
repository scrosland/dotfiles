" Add external callbacks
for fn in [
      \ 'FugitiveHead',
      \ 'WrapDescribeForStatusLine',
      \ ]
  if exists('*'.fn)
    call statusline#register_section_b_callback(function(fn))
  else
    echomsg 'No such callback: ' . string(fn)
  endif
endfor
