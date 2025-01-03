if !has("autocmd")
    finish
endif

" Provide a way to safely toggle Shfmt-on-save.
"
" Do not use g:shfmt_fmt_on_save because the way it was implemented
" makes it very hard to interactively disable after it has been set.
"
" Implement a version which can be toggled with a script local variable
" and a wrapper function to call the original shfmt.

" Wrapper for format-on-save.
" This must be called via a command to get the range defaults.
function s:shfmt_on_save_wrapper(args, line1, line2) abort
    if get(b:, 'local_shfmt_fmt_on_save', 0)
        call shfmt#shfmt(a:args, a:line1, a:line2)
    endif
endfunction
command! -range=% -nargs=? ZShfmtOnSaveWrapper call s:shfmt_on_save_wrapper(<q-args>, <line1>, <line2>)

function s:shfmt_on_save_status()
    let l:value = get(b:, 'local_shfmt_fmt_on_save', 0)
    echo "Shfmt on save: " . strpart("OffOn", 3 * l:value, 3)
endfunction
command! -nargs=0 ShfmtOnSave call s:shfmt_on_save_status()

function s:shfmt_on_save_toggle()
    let l:value = xor(get(b:, 'local_shfmt_fmt_on_save', 0), 0x1)
    let b:local_shfmt_fmt_on_save = l:value
    call s:shfmt_on_save_status()
endfunction
command! -nargs=0 ShfmtOnSaveToggle call s:shfmt_on_save_toggle()

augroup local_shfmt
    autocmd!
    " For new buffers which might be shell scripts but do not yet have
    " filetype set
    autocmd BufWritePre *.sh ZShfmtOnSaveWrapper
    " For filetype `sh` buffers
    autocmd FileType sh autocmd BufWritePre <buffer> ZShfmtOnSaveWrapper
augroup end

function s:set_shfmt_args()
    let g:shfmt_extra_args = '-i ' . &l:shiftwidth . ' --func-next-line'
    " Set the local format-on-save to on by default.
    let b:local_shfmt_fmt_on_save = 1
    " Set `formatprg` to enable textobject formating like g$ or gq.
    let &l:formatprg='shfmt ' . g:shfmt_extra_args
endfunction

" Set up shfmt
augroup filetype_shell_shfmt
    autocmd!
    autocmd FileType sh call s:set_shfmt_args()
augroup end
