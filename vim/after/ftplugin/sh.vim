if !has("autocmd")
    finish
endif

" Get rid of the vim-shfmt autocommands if they were set up.
augroup shfmt
    autocmd!
augroup end
augroup! shfmt
