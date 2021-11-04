" Commands to get a list of files from a git style diff, or diff -u patch.
command! -nargs=0 GetFilesFromGitDiff :call diff#getFilesFromDiff({'strip': 1})
command! -nargs=0 GetFilesFromPatch   :call diff#getFilesFromDiff({})

function! s:warning(msg)
        echohl WarningMsg | echom a:msg | echohl None
endfunction

function! s:in_git_repo()
    if !exists('*FugitiveGitDir')
        return 0
    endif
    if strlen(FugitiveGitDir()) == 0
        try | call FugitiveDetect(getcwd()) | catch | endtry
    endif
    return strlen(FugitiveGitDir()) > 0
endfunction

function! s:CheckInTool()
    if s:in_git_repo()
        tabnew | Git | only
    elseif exists('*CheckInTool')
        call CheckInTool()
    else
        call s:warning('The current directory is not in a source repository')
    endif
endfunction

function! s:CheckInToolWithRepo(repo)
    " create a new tab page so that we have an empty buffer in which to lcd
    " and then later the buffer can be deleted (taking the tab page with it)
    " and hence the cleaning up the lcd
    tabnew | redraw
    let l:bufnr = bufnr("")
    execute 'lcd' a:repo
    call s:CheckInTool()
    execute 'bdelete' l:bufnr
endfunction

function! s:CheckInToolCommand(...)
    let l:repo = len(a:000) > 0 && len(a:1) > 0 ? a:1 : getcwd()
    call s:CheckInToolWithRepo(l:repo)
endfunction

command! -nargs=? -bar -complete=dir CheckInTool call s:CheckInToolCommand(<q-args>)

function! Tapi_CheckInTool(bufnum, arglist)
    let repo = a:arglist[0]
    call s:CheckInToolWithRepo(l:repo)
endfunction

function! s:init_gitcommit()
    setlocal spell
    if getline(2) =~# '\v\C^# Please enter the commit message for your changes.'
        GetFilesFromGitDiff
    endif
endfunction

augroup gitcommit_filetype
    autocmd!
    autocmd FileType gitcommit call s:init_gitcommit()
augroup END
