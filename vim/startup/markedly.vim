" --- Markdown Preview Support ---
"
" Interface to either Marked 2 (via the vim-marked plugin),
" or the markdown-preview plugin.
"

if exists('g:vimrc_markedly')
    finish
endif
let g:vimrc_markedly = 1

" --- Utility functions ---

" Find plugins in vim-plug's list
function! s:have_plugin(name)
    if !exists('g:plugs')
        return 0
    end
    return has_key(g:plugs, a:name)
endfunction

" --- Either vim-marked setup ---

if s:have_plugin("vim-marked")
    command! -nargs=0 MarkdownPreview MarkedOpen!

" --- Or markdown-preview.vim setup ---

elseif s:have_plugin("markdown-preview.vim")
    let g:mkdp_auto_start = 0
    let g:mkdp_auto_open = 0
    let g:mkdp_auto_close = 1
    let g:mkdp_command_for_global = 1

    function! s:browser_osx()
        return "open -a Safari"
    endfunction
    function! s:browser_unix()
        if executable("gnome-open")
            return "gnome-open"
        else
            return "xdg-open"
        end
    endfunction

    function! s:find_app(prefixes, base)
        for l:prefix in a:prefixes
            let l:path = l:prefix . a:base
            if executable(l:path)
                return l:path
            end
        endfor
        return ""
    endfunction

    function! s:browser_windows_like(prefixes)
        let l:base = "/Google/Chrome/Application/chrome.exe"
        let l:path = s:find_app(a:prefixes, l:base)
        if strlen(l:path)
            return l:path
        end
        " fallback which will almost certainly fail
        return "chrome.exe"
    endfunction

    function! s:browser_windows()
        " markdown-preview adds the necessary '!start' prefix
        let l:prefixes = [ "C:\\Program Files", "C:\\Program Files (x86)" ]
        return s:browser_windows_like(l:prefixes)
    endfunction

    function! s:browser_wsl()
        let l:prefixes = [ 
                \ "/mnt/c/Program Files",
                \ "/mnt/c/Program Files (x86)"
                \ ]
        return s:browser_windows_like(l:prefixes)
    endfunction

    let g:mkdp_path_to_chrome = s:browser_{g:system_type}()
end
