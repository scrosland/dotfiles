" --- Markdown task list support ---
"
" Support GFM style task lists in markdown with a toggle for (un)done
"

if exists('g:vimrc_mkdtasks')
    finish
endif
let g:vimrc_mkdtasks = 1

function! s:mkdtasks_setup()
    nnoremap <LocalLeader>d :call mkdtasks#toggle()<CR>
endfunction

if has("autocmd")
    augroup mkdtasks
        autocmd!
        autocmd FileType markdown call s:mkdtasks_setup()
        autocmd FileType mkd      call s:mkdtasks_setup()
    augroup end
endif

