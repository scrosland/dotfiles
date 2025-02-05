if exists('b:loaded_python_black')
  finish
endif
let b:loaded_python_black = 1

" I don't use the 'psf/black' vim plugin, instead I install black using the
" system package manager or homebrew

let &l:formatprg = 'black --line-length 80 --quiet -'

" TODO: Add a toggle for format on save
