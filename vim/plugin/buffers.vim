" ----- Simple BufExplorer alternative -----

function! s:BufSelect(command)
    ls | call feedkeys(':'.a:command.' ', 'n')
endfunction

function! BufSelectComplete(partial, cmdline, pos)
    return ['bdelete', 'buffer']
endfunction

command! -nargs=1 -complete=customlist,BufSelectComplete
    \ Bselect call s:BufSelect(<q-args>)
command! -nargs=0 Buffy call s:BufSelect('buffer')
nnoremap <Leader>be :Buffy<CR>

" ----- Buffer cleanup -----

let g:buf_cleanup_actions = {
    \ 'invisible': 'empty(v:val.windows)',
    \ 'nameless' : 'v:val.name == ""',
    \ 'other'    : 'v:val.bufnr != bufnr()',
    \ }

" action : which types of buffers to :bdelete
function! s:BufCleanup(action)
    let l:condition = get(g:buf_cleanup_actions, a:action, '')
    if l:condition == ''
        echohl WarningMsg | echo 'Unknown action: '.a:action | echohl None
        return
    endif
    let l:bufinfo = filter(filter(getbufinfo(), 'v:val.listed'), l:condition)
    let l:bufnumbers = map(l:bufinfo, 'v:val.bufnr')
    if empty(l:bufnumbers)
        echohl MoreMsg | echo 'No '.a:action.' buffers to cleanup' | echohl None
    else
        echo 'Cleaning up buffer numbers: '.join(l:bufnumbers, ', ')
        execute 'bdelete '.join(l:bufnumbers)
    endif
endfunction

function! BufCleanupComplete(partial, cmdline, pos)
    return keys(g:buf_cleanup_actions)
endfun

command! -nargs=1 -complete=customlist,BufCleanupComplete
    \ Bcleanup call s:BufCleanup(<q-args>)

" ----- Buffer delete, next, previous with tab awareness -----

function! s:EventDebug(event)
    let l:bufnr = 0+expand('<abuf>')
    let l:bufname = bufname(l:bufnr)
    echohl Debug | echom ''.a:event.': '.l:bufnr.', '.l:bufname | echohl None
endfunction

function! s:AddBufferEvt()
    if !exists('t:buffer_list')
        let t:buffer_list = {}
    endif
    let l:bufnr = 0+expand('<abuf>')
    if getbufvar(l:bufnr, '&buflisted') && getbufvar(l:bufnr, '&modifiable')
        let t:buffer_list[l:bufnr] = bufname(l:bufnr)
    endif
endfunction

function! s:DelBufferEvt()
    try | call remove(t:buffer_list, 0+expand('<abuf>')) | catch | endtry
endfunction

"augroup BufferEvtDebug
"    autocmd!
"    for evt in [
"                \ 'WinEnter', 'BufWinEnter', 'BufEnter',
"                \ 'BufDelete', 'BufHidden', 'BufUnload'
"                \ ]
"        execute 'autocmd '.evt.' * call s:EventDebug("'.evt.'")'
"    endfor
"augroup END

augroup TabBufferList
    autocmd!
    autocmd BufWinEnter * call s:AddBufferEvt()
    autocmd BufEnter * call s:AddBufferEvt()
    " BufDelete is sent when nobuflisted is set (confirmed in the vim source)
    autocmd BufDelete * call s:DelBufferEvt()
augroup END

function! s:Candidate(idx, bufinfo)
    return has_key(t:buffer_list, a:bufinfo.bufnr)
        \ && len(a:bufinfo.windows) == 0
        \ && has_key(a:bufinfo.variables, 'term_title') == 0
        \ && has_key(a:bufinfo.variables, 'neoterm_id') == 0
endfunction

function! s:Bdelete(bang)
    let l:bufnr_to_delete = bufnr()
    let l:bufinfo = filter(getbufinfo({'buflisted': 1}), function('s:Candidate'))
    if len(l:bufinfo) > 0
        call s:NextOrPrev(a:bang, 1, map(l:bufinfo, 'v:val.bufnr'))
    endif
    let l:bang = a:bang ? '!' : ''
    " if NextOrPrev() did not change buffer, or wasn't called, create a new one
    if bufnr() == l:bufnr_to_delete
        execute 'enew'.l:bang
    endif
    " only delete the buffer if it's not still visible in a window
    if empty(win_findbuf(l:bufnr_to_delete))
        execute 'bdelete'.l:bang.' '.l:bufnr_to_delete
    endif
endfunction

command! -nargs=0 -bang -bar Bdelete call s:Bdelete(<bang>0)
command! -nargs=0 -bang -bar BD call s:Bdelete(<bang>0)

function! s:NextOrPrev(bang, direction, ...)
    let l:input = a:0 > 0 ? a:1 : keys(t:buffer_list)
    let l:buffers = sort(copy(l:input), 'N')
    if a:direction > 0
        let l:buffers = reverse(l:buffers)
    endif
    let l:current = bufnr()
    let l:target = l:buffers[-1]
    for l:bufnr in l:buffers
        if l:bufnr == l:current
            break
        endif
        let l:target = l:bufnr
    endfor
    if l:target != l:current
        let l:bang = a:bang ? '!' : ''
        execute 'buffer'.l:bang.' '.l:target
    endif
endfunction

function! s:Bnext(bang)
    call s:NextOrPrev(a:bang, 1)
endfunction

command! -nargs=0 -bang -bar Bnext call s:Bnext(<bang>0)
command! -nargs=0 -bang -bar BN call s:Bnext(<bang>0)

function! s:Bprev(bang)
    call s:NextOrPrev(a:bang, -1)
endfunction

command! -nargs=0 -bang -bar Bprev call s:Bprev(<bang>0)
command! -nargs=0 -bang -bar BP call s:Bprev(<bang>0)
