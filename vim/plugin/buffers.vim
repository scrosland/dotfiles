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

function! s:AddBufferEvt()
    let l:bufnr = 0+expand('<abuf>')
    let g:sc#buffers[l:bufnr] = localtime()
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
    let l:bwidth = max([3, len(string(bufnr('$')))])
    let l:name = GetBufferName(a:bufnr)
    let l:bufinfo = getbufinfo(a:bufnr)[0]
    let l:thisthat = a:bufnr == bufnr('') ? '%' : a:bufnr == bufnr('#') ? '#' : ' '
    let l:flag = l:thisthat
    let l:flag .= l:bufinfo.loaded && l:bufinfo.hidden ? 'h' :
                \ l:bufinfo.loaded && len(l:bufinfo.windows) > 0 ? 'a' : ' '
    if getbufvar(a:bufnr, '&buftype') == 'terminal'
        let l:name .= ' ['.term_gettitle(a:bufnr).']'
        let l:flag .= term_getjob(a:bufnr) == v:null ? '?' :
                    \ term_getstatus(a:bufnr) =~ 'running' ? 'R' : 'F'
    else
        let l:flag .= getbufvar(a:bufnr, '&modifiable') == 0 ? '-' :
                    \ getbufvar(a:bufnr, '&readonly') ? '=' : ' '
        let l:flag .= l:bufinfo.changed ? '+' : ''
    endif
    let l:lineno = l:bufinfo.lnum
    " key is the search key for fzf (--nth=1), \t is the field separator,
    " the rest of the line is the information to be displayed (--with-nth=2..)
    let l:key = ''.a:bufnr.':'.l:thisthat.':'.l:name
    return printf("%s\t%*s %-4s %-40s line %s", l:key, l:bwidth, a:bufnr, l:flag, l:name, l:lineno)
endfunction

let g:fzf_buffer_actions = {
            \ 'open'   : { 'multi': 0, 'command': 'buffer' },
            \ 'delete' : { 'multi': 1, 'command': 'bdelete' },
            \ }

function! s:bufopen(action, lines)
    if empty(a:lines)
        return
    endif
    let l:action_opts = g:fzf_buffer_actions[a:action]
    " matches the bufnr in the key in the printf() in s:format_buffer()
    let l:buffers = map(a:lines, 'matchstr(v:val, ''^\zs[0-9]\{1,}\ze:'')')
    if l:action_opts.multi == 0
        let l:buffers = l:buffers[-1:]
    endif
    execute l:action_opts.command join(l:buffers)
endfunction

function! s:fzf_buffers(action, query, bang)
    let l:action_opts = g:fzf_buffer_actions[a:action]
    let l:buflist = filter(range(1, bufnr('$')),
        \ 'buflisted(v:val) && getbufvar(v:val, "&filetype") != "qf"')
    let l:sorted = sort(l:buflist, 's:sort_buffers')
    let l:source = map(l:sorted, 's:format_buffer(v:val)')
    return fzf#run(fzf#wrap('buffers', {
                \ 'source' : l:source,
                \ 'sink*'  : function('s:bufopen', [a:action]),
                \ 'options': [ l:action_opts.multi ? '--multi' : '--no-multi',
                                \ '--bind', 'ctrl-a:select-all,ctrl-t:toggle',
                                \ '-d', "\t", '--nth=1', '--with-nth=2..',
                                \ '--prompt', 'Buffer('.a:action.')> ',
                                \ '--query', a:query,
                                \ '--tiebreak=index',
                                \ ],
                \ }, a:bang))
endfunction

command! -nargs=? -bang -bar -complete=buffer
            \ Buffy call s:fzf_buffers('open', <q-args>, <bang>0)
nnoremap <Leader>bb :Buffy<CR>

command! -nargs=? -bang -bar -complete=buffer
            \ Bdeletor call s:fzf_buffers('delete', <q-args>, <bang>0)
