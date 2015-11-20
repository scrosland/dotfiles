## For Linux/Unix:

  1. `git clone https://github.com/scrosland/dotfiles $HOME/dotfiles`

  1. Copy profile.sample and bashrc.sample to $HOME/.profile and .bashrc, or
     otherwise configure the same files.

  1. `ln -s $HOME/dotfiles/vimrc $HOME/.vimrc`

  1. Create $HOME/.vimrc.local if required.

  1. Ensure ruby is installed.

  1. sudo gem install markedly

  1. `mkdir -p $HOME/.vim/bundle`

  1. `git clone http://github.com/gmarik/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim`

  1. `vim -c ":PluginInstall"`


## For Mac OS X:

Follow the Linux/Unix instructions, but instead of installing the markedly ruby
gem, install Marked2 from http://marked2app.com/.


## For Windows:

  1. Install git from https://git-scm.com/download/win. Configure to be
     accessible from cmd as well as bash.

  1. Install vim from http://www.vim.org/download.php.

  1. Install ruby 1.9.3 and the associated devkit from
     http://rubyinstaller.org/downloads/.

  1. Install DejaVu fonts from http://dejavu-fonts.org/.

  1. (Optional) Install Github Desktop from https://desktop.github.com/.

  1. Start cmd and
  
      ```
      cd %USERPROFILE%
      mkdir %USERPROFILE%\vimfiles\bundle
      git clone https://github.com/scrosland/dotfiles %USERPROFILE%\dotfiles
      git clone https://github.com/gmarik/Vundle.vim.git %USERPROFILE%\vimfiles\bundle\Vundle.vim
      gem install markedly
      ```

  1. Edit `C:\Program Files (x86)\Vim\_vimrc` so it contains:

      ```
      set nocompatible
      source $USERPROFILE/dotfiles/vimrc
      ```

  1. Create "%USERPROFILE%/vimfiles/vimrc.local" if required.

  1. `gvim -c ":PluginInstall"` or start Gvim from the menu and then `:PluginInstall`

