" --- Plugin bootstrap for vim-plug ---

function! plugins#bootstrap()
    if exists('*plug#begin')
        echom "Plugin bootstrap skipped: vim-plug is already installed."
        echom "Run :PlugStatus to determine plugin status."
        return
    endif

    let l:vimplug = expand(g:plugins_basedir . '/autoload/plug.vim')
    if g:is_windows
        let l:url = 'https://github.com/junegunn/vim-plug'
        echom "See instructions at " . l:url .
                \ " and save as '" . l:vimplug . "'"
        return
    endif

    let l:url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    echo "Downloading vim-plug to " . l:vimplug . " ..."
    redraw
    try
        silent let l:out = system(
            \ printf('curl -fLo %s --create-dirs %s', l:vimplug, l:url))
        if v:shell_error
            echoerr "Error downloading vim-plug: " . l:out
            return
        endif
    catch
        echoerr "Exception while downloading vim-plug: " . v:exception
        return
    endtry

    try
        call mkdir(g:plugins_bundledir, 'p')
    catch
        echoerr "Exception while creating bundle directory: " . v:exception
        return
    endtry

    echom "vim-plug installed. Restart vim and run :PlugStatus and :PlugInstall"
endfunction
