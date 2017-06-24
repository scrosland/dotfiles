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
    execute "edit! +" . l:line . " " . l:file
    execute "doautocmd BufNewFile " . l:file
  endfunction

  " The public interface
  function! openat#open()
    call s:open_file_at_line()
  endfunction

  augroup openat#augroup
    autocmd!
    autocmd BufNewFile *:*:* call openat#open()
  augroup END
endif