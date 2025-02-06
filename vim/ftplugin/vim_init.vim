" loaded once for each file of this type, so uses buffer or window local variables
if exists('b:loaded_vim_init')
  finish
endif
let b:loaded_vim_init = 1

" vim files should support folding based on markers, but start unfolded
setlocal foldmethod=marker nofoldenable
