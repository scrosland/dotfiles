## For Linux/Unix:

  ```
  git clone https://github.com/scrosland/dotfiles $HOME/dotfiles
  git config --global core.excludesfile $HOME/dotfiles/gitignore.global
  # Copy skeleton/* the equivalent $HOME/.* files,
  # or otherwise configure the same files.
  # This is one option:
  echo ". \$HOME/dotfiles/startup" >$HOME/.bashrc
  echo ". \$HOME/dotfiles/startup" >$HOME/.profile
  echo "\$include $HOME/dotfiles/inputrc" >$HOME/.inputrc
  echo "source \$HOME/dotfiles/vim/vimrc" > $HOME/.vimrc
  echo "source \$HOME/dotfiles/vim/gvimrc" > $HOME/.gvimrc
  # Create $HOME/.vim/after/plugin/local.vim if required.
  # Create $HOME/.{environment,functions,shrc}.local if required.
  vim -c "call plugins#bootstrap()"
  ```


## For Mac OS X:

  1. Follow the Linux/Unix instructions.
  1. If applications need to be installed to the user Applications folder:
    `touch $HOME/.install_to_user_applications`
  1. Run `$HOME/dotfiles/mac/install.sh` to install some basics.
  1. Install Marked2 from http://marked2app.com.


## For Windows:

  1. Install git from https://git-scm.com/download/win. Configure to be accessible from cmd as well as bash.

  1. Install vim from http://www.vim.org/download.php.

  1. Install DejaVu fonts from http://dejavu-fonts.org/.

  1. (Optional) Install Github Desktop from https://desktop.github.com/.

  1. Start cmd and

      ```
      cd %USERPROFILE%
      mkdir %USERPROFILE%\vimfiles\autoload
      mkdir %USERPROFILE%\vimfiles\bundle
      git clone https://github.com/scrosland/dotfiles %USERPROFILE%\dotfiles
      git config --global core.excludesfile %USERPROFILE%\dotfiles\gitignore.global
      ```

  1. Edit `C:\Program Files (x86)\Vim\_vimrc` so it contains:

      ```
      set nocompatible
      source $USERPROFILE/dotfiles/vim/vimrc
      ```

  1. Edit `C:\Program Files (x86)\Vim\_gvimrc` so it contains:

      ```
      source $USERPROFILE/dotfiles/vim/gvimrc
      ```

  1. Create `%USERPROFILE%/vimfiles/after/plugin/local.vim` if required.

  1. `gvim -c "plugins#bootstrap()"` and follow the instructions.

