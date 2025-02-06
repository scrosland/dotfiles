" loaded once for each file of this type, so uses buffer or window local variables
if exists('b:loaded_golang_init')
  finish
endif
let b:loaded_golang_init = 1

setlocal noexpandtab nosmarttab softtabstop=0 shiftwidth=8 tabstop=8
