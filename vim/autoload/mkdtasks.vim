" --- Markdown task list support ---
"
" Support GFM style task lists in markdown with a toggle for (un)done
"
" Based on ideas from 
" https://github.com/bgrundmann/mkdtodo
" and
" https://github.com/polm/github-tasks.vim
"

function! mkdtasks#toggle()
    let l:winview = winsaveview()
    let l:line = getline(".")
    let l:num_spaces = match(l:line, "-")
    let l:spaces = repeat(" ", l:num_spaces)
    if l:line =~? '^\s*- \[ \]'
        " not done, mark done
        let l:line = substitute(l:line, '^\s*- \[ \]', l:spaces . "- [x]", "")
    elseif l:line =~? '^\s*- \[[xX]\]'
        " done, mark undone
        let l:line = substitute(l:line, '^\s*- \[[xX]\]', l:spaces . "- [ ]", "")
    elseif l:line =~? '^\s*-'
        " list item not a task, make it one
        let l:line = substitute(l:line, '^\s*-', l:spaces . "- [ ]", "")
    else
        " not a task or a list item, make it a task
        let l:line = substitute(l:line, '^\(\s*\)\(.*\)', '\1' . '- [ ] ' . '\2', "")
    endif
    call setline(".", l:line)
    call winrestview(l:winview)
endfunction
