command! -nargs=+ -bar EditBase64EncodedNames 
    \ call base64names#DecodeAndEdit(<f-args>)
