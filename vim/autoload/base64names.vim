function! s:decode(b64)
    return pyxeval('base64.b64decode("' . a:b64 . '")')
endfunction

function! base64names#DecodeAndEdit(...)
    pythonx import base64
    execute 'args ' . fnameescape(s:decode(a:000[0]))
    for f in a:000[1:]
        execute 'argadd ' . fnameescape(s:decode(f))
    endfor
endfunction
