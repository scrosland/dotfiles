function! EditBase64EncodedNames(...)
    let bufnr = bufnr('%')
    if bufnr != 1
        let bufnr += 1
    endif
    pythonx import base64
    for b64 in a:000
        let name = pyxeval('base64.b64decode("' . b64 . '")')
        execute 'edit ' . name
    endfor
    try
        execute 'silent buffer ' . bufnr
    catch
    endtry
endfunction

command! -nargs=+ -bar EditBase64EncodedNames call EditBase64EncodedNames(<f-args>)
