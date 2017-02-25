## For Linux/Unix:

  ```
  git clone https://github.com/scrosland/dotfiles $HOME/dotfiles
  # Copy profile.sample and bashrc.sample to $HOME/.profile and .bashrc,
  # or otherwise configure the same files.
  # This is one option:
  echo ". \$HOME/dotfiles/startup" >$HOME/.bashrc
  echo ". \$HOME/dotfiles/startup" >$HOME/.profile
  echo "\$include $HOME/dotfiles/inputrc" >$HOME/.inputrc
  echo "source \$HOME/dotfiles/vimrc" > $HOME/.vimrc
  # Create $HOME/.vimrc.local if required.
  vim -c "call plugins#bootstrap()"
  ```


## For Mac OS X:

  1. Run `$HOME/dotfiles/install-mac.sh` to install some basics.
  1. Follow the Linux/Unix instructions.
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
      ```

  1. Edit `C:\Program Files (x86)\Vim\_vimrc` so it contains:

      ```
      set nocompatible
      source $USERPROFILE/dotfiles/vimrc
      ```

  1. Create `%USERPROFILE%/vimfiles/vimrc.local` if required.

  1. `gvim -c "plugins#bootstrap()"` and follow the instructions.

