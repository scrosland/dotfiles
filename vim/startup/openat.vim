" --- Support for opening files at a specified position ---
"
" If the filename looks like 'grep --with-filename --line-number' output,
" open the file at the named line number.
" E.g. given this:
"   vim dotfiles/vimrc:155: ...
" open the 'dotfiles/vimrc' file at line 155.
"

if exists('g:vimrc_openat')
  finish
endif
let g:vimrc_openat = 1

if has("autocmd")
  function! s:open_file_at_line()
    let l:arg = expand("%:p") . "junk"
    " See ':help list' and the section on 'List unpack'
    let [l:file, l:line; rest] = split(l:arg, ":")
    let l:initial_buffer = winbufnr(0)
    execute "edit! +" . l:line . " " . l:file
    execute "doautocmd BufNewFile " . l:file
    execute "bdelete " . l:initial_buffer
  endfunction

  " The public interface
  function! OpenAtLine()
    call s:open_file_at_line()
  endfunction

  augroup open_at_line
    autocmd!
    autocmd BufNewFile *:*:* call OpenAtLine()
  augroup END
endif
