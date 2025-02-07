" Loaded once per buffer
if exists('b:loaded_cpp_tools')
  finish
endif
let b:loaded_cpp_tools = 1

if !exists('*CppTool')
    function! CppTool(name, args)
        if !executable(a:name)
            echoerr a:name . ' is not installed'
            return
        endif
        if &diff
            echoerr 'Cannot run ' . a:name ' in diff mode'
            return
        endif
        let l:original_makeprg = &makeprg
        let l:makeprg = join(a:args, ' ')
        make
        let &makeprg = l:original_makeprg
    endfunction
endif

if !exists(':CppCheck')
    " Options to consider:
    "   --template=gcc
    "   --enable=warning
    "   --enable=style
    "   --suppress=...
    let s:cppcheck_argv = [
    \   'cppcheck',
    \   '--quiet',
    \   '--error-exitcode=1',
    \   '--language=c++',
    \   '%:p',
    \]
    command! -nargs=0 -bar CppCheck call CppTool('cppcheck', s:cppcheck_argv)
endif

" TODO: move the clang-format style options to this file and add a clang-format command

if !exists('g:cpp_tools_clang_format_cache')
    " {root_path -> format}
    let g:cpp_tools_clang_format_cache = {}
endif

let s:clang_format_definitions = {
\   'legacy': '{ BasedOnStyle: Google, IndentWidth: 4, TabWidth: 4, ColumnLimit: 0, BreakConstructorInitializers: BeforeComma, AccessModiferOffset: -2, IncludeBlocks: Preserve, SortIncludes: Never }',
\   'modern': 'Google',
\}

function! s:clang_format_name()
    let l:root = g:user.project.root_path()
    if len(l:root) == 0
        return 'modern'
    endif
    let l:format = get(g:cpp_tools_clang_format_cache, l:root, '')
    if len(l:format) != 0
        return l:format
    endif
    if isdirectory(l:root . '/.bk') || isdirectory(l:root . '/BitKeeper')
        let l:format = 'legacy'
    else
        let l:format = 'modern'
    endif
    let g:cpp_tools_clang_format_cache[l:root] = l:format
    return l:format
endfunction

if !exists('*CppToolsClangFormatString')
    function! CppToolsClangFormatString()
        return get(s:clang_format_definitions, s:clang_format_name(), '')
    endfunction
endif

function! s:clang_format_argv()
    return [
    \   'clang-format',
    \   '--style=' . CppToolsClangFormatString(),
    \]
endfunction

command! -nargs=0 -bar CppFormat call CppTool('clang-format', s:clang_format_argv())
