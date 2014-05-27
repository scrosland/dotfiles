" --- Markdown Preview support ---
"
" Using rubygems "markedly" on unix and Windows, or Marked.app on OSX.
"

" --- Options ---

let g:markedly_options = [
  \ '--parse-no-intra-emphasis',
  \ '--parse-tables',
  \ '--parse-fenced-code-blocks',
  \ '--parse-autolink',
  \ '--parse-strikethrough',
  \ '--render-with-toc-data',
  \ ]

" --- Utilities ---

function! s:current_file()
  return shellescape(expand('%:p'))
endfunction

function! s:cleanup_group(tag)
  return "markedly_cleanup_" . a:tag
endfunction

function! s:tag()
  return substitute(tempname(), "[\\/]", '', 'g')
endfunction

" --- Automatic cleanup ---

function! s:add_cleanup(tag, fn)
  silent! execute 'augroup ' . s:cleanup_group(a:tag)
    autocmd!
    silent! exe 'autocmd BufDelete <buffer> call ' . a:fn . '("' . a:tag . '")'
    silent! exe 'autocmd VimLeavePre * call ' . a:fn . '("' . a:tag . '")'
  augroup END
endfunction

function! s:remove_cleanup(tag)
  silent! execute 'augroup ' . s:cleanup_group(a:tag)
    autocmd!
  augroup END
  silent! execute 'augroup! ' . s:cleanup_group(a:tag)
endfunction!

" --- System specific implementations ---

" --- OSX: using Marked.app if possible ---

function! s:markedly_osx()
  if exists(":MarkedOpen")
    " use the vim-marked plugin
    return "MarkedOpen!"
  endif
  return s:markedly_unix()
endfunction

" --- Unix: running markedly in a detached screen session ---

function! s:markedly_unix()
  let l:tag = s:tag()
  call s:add_cleanup(l:tag, "s:markedly_cleanup_unix")
  let l:command = '!screen -S "' . l:tag . '" -dmU '
  let l:command = l:command . 'markedly ' . join(g:markedly_options, ' ')
  let l:command = l:command . ' ' . s:current_file()
  return l:command
endfunction

function! s:markedly_cleanup_unix(tag)
  call s:remove_cleanup(a:tag)
  silent! execute '!screen -S "' . a:tag . '" -X quit'
endfunction!

" --- Windows ---
"
" It would be great to use the same trick as on linux, and schtasks is close
" but will not kill markedly properly :(

function! s:markedly_windows()
  let l:command = '!start cmd /c cd C:\Ruby193\bin&'
  let l:command = l:command . 'ruby markedly ' . join(g:markedly_options, ' ')
  let l:command = l:command . ' ' . s:current_file() . '&pause'
  return l:command
endfunction

" --- Main entry point ---

function! s:markedly()
  try
    let l:command = s:markedly_{g:system_type}()
  catch
    throw "s:markedly() has not been implemented for this platform"
  endtry
  silent! execute l:command
endfunction

command! -nargs=0 MarkdownPreview call s:markedly()
