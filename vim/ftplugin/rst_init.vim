" loaded once for each file of this type, so uses buffer or window local variables
if exists('b:loaded_rst_init')
  finish
endif
let b:loaded_text_init = 1

call textlike#buffer_init()
setlocal nofoldenable
