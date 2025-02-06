if exists('g:loaded_textlike')
    finish
endif
let g:loaded_textlike = 1

function! textlike#buffer_init() abort
    iab <buffer> -- <c-k>n-
    iab <buffer> ~~ <c-k>m-
    setlocal spell
    WrapSoft
endfunction
