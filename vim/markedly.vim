let g:markedly_options = [
  \ '--debug',
  \ '--parse-no-intra-emphasis',
  \ '--parse-tables',
  \ '--parse-fenced-code-blocks',
  \ '--parse-autolink',
  \ '--parse-strikethrough',
  \ '--render-with-toc-data',
  \ ]

function! s:current_file()
  return shellescape(expand('%:p'))
endfunction

function! s:markedly_osx()
  if exists(":MarkedOpen")
    " use the vim-marked plugin
    return "MarkedOpen!"
  endif
  return s:markedly_unix()
endfunction

function! s:markedly_unix()
  let l:command = '!run-in-terminal -t markedly '
  let l:command = l:command . 'markedly ' . join(g:markedly_options, ' ')
  let l:command = l:command . ' ' . s:current_file()
  return l:command
endfunction

function! s:markedly_windows()
  let l:command = '!start cmd /c cd C:\Ruby193\bin&'
  let l:command = l:command . 'ruby markedly ' . join(g:markedly_options, ' ')
  let l:command = l:command . ' ' . s:current_file() . '&pause'
  return l:command
endfunction

function! s:markedly()
  try
    let l:command = s:markedly_{g:system_type}()
  catch
    throw "s:markedly() has not been implemented for this platform"
  endtry
  silent! execute l:command
endfunction
command! -nargs=0 MarkdownPreview call s:markedly()
