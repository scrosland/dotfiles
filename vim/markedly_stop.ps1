# PowerShell script to stop (kill) markedly
# 
# usage:
#   markedly_stop.ps1 <filename of markdown file>
#

# Have to replace '\' in pathname with '\\' otherwise the backslashes are
# interpretted as regex escape characters! This loks wrong, but isn't.
$path = $Args[0] -replace "\\", '\\'

$process_list = Get-WmiObject win32_process `
                  -filter "CommandLine like '%markedly%'" |
                    Where-Object {$_.CommandLine -imatch $path}

foreach ($process in $process_list) {
  Stop-Process -force -id $process.ProcessId
}
