" loaded once for each file of this type, so uses buffer or window local variables
if exists('b:loaded_sh_init')
  finish
endif
let b:loaded_sh_init = 1

if has("autocmd")
    " Get rid of the vim-shfmt autocommands if they were set up.
    augroup shfmt
        autocmd!
    augroup end
    augroup! shfmt
endif

SetShiftWidth 4
