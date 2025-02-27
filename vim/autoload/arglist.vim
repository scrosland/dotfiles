function! s:decode(b64)
    return py3eval('base64.b64decode("' . a:b64 . '")')
endfunction

function! arglist#EditArgList(arglist)
    execute 'arglocal ' . join(map(a:arglist, {_,v -> fnameescape(v)}))
endfunction

function! arglist#DecodeAndEdit(...)
    python3 import base64
    call arglist#EditArgList(map(copy(a:000), {_,v -> s:decode(v)}))
endfunction
