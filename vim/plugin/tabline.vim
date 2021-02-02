"
" based on the example at 'setting-tabline' in vim help
"
function TabLine()
    let s = ''
    for i in range(tabpagenr('$'))
        " select the highlighting
        if i + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif

        let l:modified = ''
        for bufnr in tabpagebuflist(i+1)
            if getbufvar(bufnr, "&modified")
                    \ && getbufvar(bufnr, "&syntax") != "neoterm"
                let l:modified = '+'
                break
            endif
        endfor

        " number and modified indicator
        let s .= '['.(i+1).l:modified.']'

        " set the tab page number (for mouse clicks)
        let s .= '%' . (i + 1) . 'T'

        " the label is made by GetTabLabel()
        let s .= ' %{GetTabLabel(' . (i + 1) . ')} '
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'

    " right-align the label to close the current tab page
    if tabpagenr('$') > 1
        let s .= '%=%#TabLine#%999Xclose'
    endif

    return s
endfunction

function GetTabLabel(n)
    let tabname = gettabvar(a:n, "tab_name", "")
    if strlen(tabname)
        return tabname
    end
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    return pathshorten(GetBufferName(buflist[winnr - 1]))
endfunction

function s:Error(message)
    echohl ErrorMsg | echo a:message | echohl None
endfunction

function s:ClearTabName(bang)
    if !a:bang
        call s:Error("Use :TabName! to clear the tab name")
        return
    endif
    unlet t:tab_name
    call s:RefreshTabs()
endfunction

function s:SetTabName(bang, ...)
    if empty(a:000)
        return s:ClearTabName(a:bang)
    endif
    let t:tab_name = a:1
    call s:RefreshTabs()
endfunction

function s:RefreshTabs()
    set tabline=%!TabLine()
    set guitablabel=%{TabLine()}
endfunction

call s:RefreshTabs()

" To set    :TabName 'name'
" To clear  :TabName!
command! -bang -nargs=* TabName call s:SetTabName(<bang>0, <args>)
