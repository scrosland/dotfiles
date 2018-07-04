" backwards compatible vimrc until all clients are updated
execute 'source ' . expand("<sfile>:p:h") . '/vim/vimrc'
