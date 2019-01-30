" Commands to get a list of files from a git style diff, or diff -u patch.
command! -nargs=0 GetFilesFromGitDiff :call diff#getFilesFromDiff({'strip': 1})
command! -nargs=0 GetFilesFromPatch   :call diff#getFilesFromDiff({})
