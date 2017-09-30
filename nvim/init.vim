" neovim user configuration file (vimrc)

" configure to use existing vim configuration
set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
