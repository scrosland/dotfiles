" ----- Simple BufExplorer alternative -----

function! s:BufSelect(command)
    ls | call feedkeys(':'.a:command.' ', 'n')
endfunction

function! BufSelectComplete(partial, cmdline, pos)
    return filter(['bdelete', 'buffer'],
                \ 'strpart(v:val, 0, len(a:partial)) == a:partial')
endfunction

command! -nargs=1 -complete=customlist,BufSelectComplete
    \ Bselect call s:BufSelect(<q-args>)
command! -nargs=0 Buffy call s:BufSelect('buffer')
nnoremap <Leader>be :Buffy<CR>

" ----- Buffer cleanup -----

let g:buf_cleanup_actions = {
    \ 'invisible' : 'empty(v:val.windows)',
    \ 'nameless'  : 'v:val.name == ""',
    \ 'notcurrent': 'v:val.bufnr != bufnr("%")',
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
    return filter(keys(g:buf_cleanup_actions),
                \ 'strpart(v:val, 0, len(a:partial)) == a:partial')
endfun

command! -nargs=1 -complete=customlist,BufCleanupComplete
    \ Bcleanup call s:BufCleanup(<q-args>)

" ----- Buffer delete, next, previous with tab awareness -----

function! s:EventDebug(event)
    let l:bufnr = 0+expand('<abuf>')
    let l:bufname = bufname(l:bufnr)
    echohl Debug | echom ''.a:event.': '.l:bufnr.', '.l:bufname | echohl None
endfunction

if !exists('g:sc#buffers')
    " A dict of bufnr -> access time, where access time is the most recent time
    " the buffer has been visible in a window
    let g:sc#buffers = {}
endif

if exists('*reltimefloat')
    function! s:time()
        return reltimefloat(reltime())
    endfunction
else
    function! s:time()
        return localtime()
    endfunction
endif

function! s:AddBufferEvt()
    let l:bufnr = 0+expand('<abuf>')
    let g:sc#buffers[l:bufnr] = s:time()
    if !exists('t:buffer_list')
        let t:buffer_list = {}
    endif
    if getbufvar(l:bufnr, '&buflisted') && getbufvar(l:bufnr, '&modifiable')
        let t:buffer_list[l:bufnr] = bufname(l:bufnr)
    endif
endfunction

function! s:DelBufferEvt()
    try | call remove(g:sc#buffers, 0+expand('<abuf>')) | catch | endtry
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
    let l:bufnr_to_delete = bufnr('%')
    let l:bufinfo = filter(getbufinfo({'buflisted': 1}), function('s:Candidate'))
    if len(l:bufinfo) > 0
        call s:NextOrPrev(a:bang, -1, map(l:bufinfo, 'v:val.bufnr'))
    endif
    let l:bang = a:bang ? '!' : ''
    " if NextOrPrev() did not change buffer, or wasn't called, create a new one
    if bufnr('%') == l:bufnr_to_delete
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
    let l:current = bufnr('%')
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

" ----- Buffer search with added fzf fuzziness -----

" Based on ideas from Junegunn Choi in fzf.vim
" https://github.com/junegunn/fzf.vim
"
" Possible futures: a 'Bselect bdelete' variant with multi-select (--multi).

function! s:sort_buffers(...)
    " sorts by most recently used based on the time saved in the global dict
    let [b1, b2] = map(copy(a:000), 'get(g:sc#buffers, v:val, v:val)')
    return b1 < b2 ? 1 : -1
endfunction

function! s:format_buffer(bufnr)
    let l:bwidth = len(string(bufnr('$')))
    let l:name = bufname(a:bufnr)
    let l:name = empty(name) ? '[No Name]' : fnamemodify(name, ':p:~:.')
    let l:flag = a:bufnr == bufnr('') ? '%' : a:bufnr == bufnr('#') ? '#' : ' '
    return printf("%*s %s %s", l:bwidth, a:bufnr, l:flag, l:name)
endfunction

function! s:bufopen(lines)
    if empty(a:lines)
        return
    endif
    " matches the bufnr in the printf() in s:format_buffer()
    let l:bufnr = matchstr(a:lines[-1], '^\zs[0-9]\{1,}\ze ')
    if bufnr('') == l:bufnr
        return
    endif
    execute 'buffer' l:bufnr
endfunction

function! s:fzf_buffers(query, bang)
    let l:buflist = filter(range(1, bufnr('$')),
        \ 'buflisted(v:val) && getbufvar(v:val, "&filetype") != "qf"')
    let l:sorted = sort(l:buflist, 's:sort_buffers')
    let l:source = map(l:sorted, 's:format_buffer(v:val)')
    return fzf#run(fzf#wrap('buffers', {
                \ 'source' : l:source,
                \ 'sink*'  : function('s:bufopen'),
                \ 'options': [ '--no-multi',
                                \ '--prompt', 'Buffer> ',
                                \ '--query', a:query,
                                \ '--tiebreak=index',
                                \ ],
                \ }, a:bang))
endfunction

command! -nargs=? -bang -bar -complete=buffer
            \ Bbuffz call s:fzf_buffers(<q-args>, <bang>0)
nnoremap <Leader>bb :Bbuffz<CR>
