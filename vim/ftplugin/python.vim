" I don't use the 'psf/black' vim plugin, instead I install black using the
" system package manager or homebrew

let &l:formatprg = 'black --line-length 80 --quiet -'

" TODO: Add a toggle for format on save
