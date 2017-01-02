" --- Markdown Preview support ---
"
" Using rubygems "markedly" on unix and Windows, or Marked.app on OSX.
"
" Might want to replace the non-macOS implementations with
" https://github.com/iamcco/markdown-preview.vim
" which is a pure vim/python implemention which works on Linux and Windows.
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

" --- Tag to pathname cache ---

let s:tagsdict = {}

function! s:add_tag(tag, pathname)
  let s:tagsdict[a:tag] = a:pathname
endfunction

function! s:remove_tag(tag)
  if has_key(s:tagsdict, a:tag)
    call remove(s:tagsdict, a:tag)
  endif
endfunction

function! s:tag2pathname(tag)
  return s:tagsdict[a:tag]
endfunction

" --- Automatic cleanup ---

function! s:add_cleanup(tag, fn)
  let l:pathname = expand('%:p')
  call s:add_tag(a:tag, l:pathname)
  let l:cleanup = printf("%s('%s')", a:fn, a:tag)
  silent! execute 'augroup ' . s:cleanup_group(a:tag)
    autocmd!
    silent! execute 'autocmd BufDelete <buffer> call ' . l:cleanup
    silent! execute 'autocmd VimLeavePre * call ' . l:cleanup
  augroup END
endfunction

function! s:remove_cleanup(tag)
  silent! execute 'augroup ' . s:cleanup_group(a:tag)
    autocmd!
  augroup END
  silent! execute 'augroup! ' . s:cleanup_group(a:tag)
  call s:remove_tag(a:tag)
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

" --- Windows: run in minimized cmd window, and kill using powershell ---

function! s:markedly_stop()
  return shellescape(SCPathJoin(g:vimrc_extras_dir, 'markedly_stop.ps1'))
endfunction

function! s:markedly_windows()
  let l:tag = s:tag()
  call s:add_cleanup(l:tag, "s:markedly_cleanup_windows")
  let l:command = '!start /min cmd /c cd C:\Ruby193\bin&'
  let l:command = l:command . 'ruby markedly ' . join(g:markedly_options, ' ')
  let l:command = l:command . ' ' . s:current_file() . '&pause'
  return l:command
endfunction

function! s:markedly_cleanup_windows(tag)
  let l:pathname = shellescape(s:tag2pathname(a:tag))
  call s:remove_cleanup(a:tag)
  let l:command = '!start /b powershell ' . s:markedly_stop()
  let l:command = l:command . ' ' . l:pathname
  silent! execute l:command
endfunction

" --- Main entry point ---

function! s:markedly()
  try
    let l:command = s:markedly_{g:system_type}()
  catch
    echom "caught exception: " . v:exception
    throw "s:markedly() may not have been implemented for this platform"
  endtry
  silent! execute l:command
endfunction

command! -nargs=0 MarkdownPreview call s:markedly()
