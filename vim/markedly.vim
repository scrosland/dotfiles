" --- Markdown Preview Support ---
"
" Interface to either Marked 2 (via the vim-marked plugin),
" or the markdown-preview plugin.
"

" --- Utility functions ---

function! s:have_plugin(name)
  if !exists('g:vundle#bundles')
    return 0
  end
  for b in g:vundle#bundles
    if a:name == b.name
      return 1
    end
  endfor
  return 0
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
  function! s:browser_windows()
    " markdown-preview adds the necessary '!start' prefix
    let l:prefixes = [ "C:\\Program Files", "C:\\Program Files (x86)" ]
    let l:base = "\\Google\\Chrome\\Application\\chrome.exe"
    for l:prefix in l:prefixes
      let l:path = l:prefix . l:base
      if executable(l:path)
        return l:path
      end
    endfor
    " fallback which will almost certainly fail
    return "chrome.exe"
  endfunction

  let g:mkdp_path_to_chrome = s:browser_{g:system_type}()
end
