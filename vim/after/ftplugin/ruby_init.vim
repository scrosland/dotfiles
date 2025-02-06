" loaded once for each file of this type, so uses buffer or window local variables
if exists('b:loaded_ruby_init')
  finish
endif
let b:loaded_ruby_init = 1

" Reset path as the ruby ftplugin will change it to the ruby load path
setlocal path=.,,**
