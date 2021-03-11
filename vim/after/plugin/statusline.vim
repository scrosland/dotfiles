function! StatusLineGitRoot()
    if !executable('git')
        return ''
    endif
    if !exists('*FugitiveGitDir')
        return ''
    endif
    let l:parts = []
    " fugitive should have already detected a git dir
    let l:root = substitute(FugitiveGitDir(), '/.git$', '', '')
    call add(l:parts, fnamemodify(l:root, ':t'))
    " get commit and branch from fugitive
    let l:info = FugitiveStatusline()[4:-2]     " remove '[Git' and ']'
    let l:info = substitute(l:info, '\v\C\(master\)$', '', '')
    let l:info = substitute(l:info, '\v\C\(main\)$', '', '')
    if strlen(l:info) > 0
        call add(l:parts, l:info)
    endif
    return join(l:parts, '')
endfunction

" Add external callbacks
for fn in [
            \ 'StatusLineGitRoot',
            \ 'WrapDescribeForStatusLine',
            \ ]
    if exists('*'.fn)
        call StatusLineRegisterSectionBCallback(function(fn))
    else
        echomsg 'No such callback: ' . string(fn)
    endif
endfor
