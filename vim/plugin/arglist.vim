" Open a new tab and then edit the named files.
" Called via the |terminal-api| from viterm/vimr.
function! Tapi_TabEdit(bufnum, arglist)
    tabnew
    if len(a:arglist) == 0
        return
    endif
    call arglist#EditArgList(a:arglist)
    if winwidth(0) >= 160
        vertical all 2
    elseif winheight(0) > 30
        all 2
    endif
endfunction

command! -nargs=+ -bar EditBase64EncodedNames 
    \ call arglist#DecodeAndEdit(<f-args>)
