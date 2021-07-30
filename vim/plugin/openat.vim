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
    " Accept file:123 and ignore trailing characters
    let s:regexp = '\(.\{-1,}\):\(\d\+\)'
    function! s:open_file_at_line()
        let l:match = matchlist(expand('%:p'), s:regexp)
        if empty(l:match)
            return v:false
        endif
        let l:file = l:match[1]
        let l:line = l:match[2]
        if !filereadable(l:file)
            return v:false
        endif
        let l:initial_buffer = winbufnr(0)
        " Use of ++nested on the autocmd that calls this function causes
        " the usual autocmd events to be run this :edit command
        execute 'keepalt edit!' '+'..l:line fnameescape(l:file)
        execute 'bwipeout' l:initial_buffer
        return v:true
    endfunction

    " The public interface
    function! OpenAtLine()
        return s:open_file_at_line()
    endfunction

    augroup open_at_line
        autocmd!
        " Only fires for files which do not exist
        autocmd BufNewFile *:* nested call OpenAtLine()
    augroup END
endif
