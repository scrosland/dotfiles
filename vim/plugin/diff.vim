" Commands to get a list of files from a git style diff, or diff -u patch.
command! -nargs=0 GetFilesFromGitDiff :call diff#getFilesFromDiff({'strip': 1})
command! -nargs=0 GetFilesFromPatch   :call diff#getFilesFromDiff({})

function! s:in_git_repo()
    if !exists('*FugitiveGitDir')
        return 0
    endif
    if strlen(FugitiveGitDir()) == 0
        call FugitiveDetect(getcwd())
    endif
    return strlen(FugitiveGitDir()) > 0
endfunction

function! s:CheckInTool()
    if s:in_git_repo()
        tabnew | Git | only
    elseif exists('*CheckInTool')
        call CheckInTool()
    else
        echo 'The current directory is not in a source repository'
    endif
endfunction

command! -nargs=0 -bar CheckInTool call s:CheckInTool()

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
