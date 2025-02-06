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
    let s:cppcheck_args = [
    \   'cppcheck',
    \   '--quiet',
    \   '--error-exitcode=1',
    \   '--language=c++',
    \   '%:p',
    \]
    command! -nargs=0 -bar CppCheck call CppTool('cppcheck', s:cppcheck_args)
endif

" TODO: move the clang-format style options to this file and add a clang-format command

" command! -nargs=0 -bar CppFormat call CppTool('clang-format', ['clang-format', '-style=file', '-i', '%:p'])
