function! s:decode(b64)
    return pyxeval('base64.b64decode("' . a:b64 . '")')
endfunction

function! arglist#EditArgList(arglist)
    execute 'arglocal ' . join(map(a:arglist, {_,v -> fnameescape(v)}))
endfunction

function! arglist#DecodeAndEdit(...)
    pythonx import base64
    call arglist#EditArgList(map(a:000, {_,v -> s:decode(v)}))
endfunction
