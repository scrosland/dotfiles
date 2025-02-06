" loaded once for each file of this type, so uses buffer or window local variables
if exists('b:loaded_markdown_init')
  finish
endif
let b:loaded_markdown_init = 1

call textlike#buffer_init()
setlocal nofoldenable
setlocal conceallevel=2
SetShiftWidth 4
