"
" Extract all the filenames from a diff -u patch in the current buffer.
" This looks for all the --- and +++ lines and extracts the filenames.
"

" Like patch -pN
function! s:stripLeadingSlashes(path, levels)
    let l:parts = split(a:path, '/', 1)         " keep empty parts
    return join(l:parts[a:levels:], '/')
endfunction

function! s:saveFilePath(container, strip, file)
    if a:file !~# '/dev/null'
        let a:container[s:stripLeadingSlashes(trim(a:file), a:strip)] = ''
    endif
endfunction

" options - a dict of options with possible keys:
"
"   'strip': N      strip N leading directories like patch -pN
function! s:getFilesFromDiff(options)
    let l:strip = get(a:options, 'strip', 0)
    let l:files = {}
    let l:end = line('$')
    let l:idx = 1
    while l:idx < l:end
        " Read lines in chunks to avoid excessive memory usage.
        for l:line in getline(l:idx, l:idx + 1000)
            " Regexp ...
            "   <start of line>
            "   ('---' or '+++')
            "   <space>
            "   set 'start of match' (\zs)
            "   match (return) anything else
            let l:match = matchstr(l:line, '^\([-]\{3}\|[+]\{3}\) \zs.*')
            if strlen(l:match) > 0
                call s:saveFilePath(l:files, l:strip, l:match)
            endif
            if strlen(matchstr(l:line, '^diff --git')) > 0
                for l:match in split(l:line)[2:]
                    call s:saveFilePath(l:files, l:strip, l:match)
                endfor
            endif
        endfor
        let l:idx += 1000
    endwhile
    let l:textlines = map(sort(keys(l:files)), {idx,val -> val . ': '})
    call append(line('.'), l:textlines)
    execute 'normal! ' . len(l:textlines) . 'j$'
endfunction

function! diff#getFilesFromDiff(options)
    call s:getFilesFromDiff(a:options)
endfunction
