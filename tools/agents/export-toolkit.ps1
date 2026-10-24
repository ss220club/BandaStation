param([Parameter(Mandatory=$true)][string]$Destination)
. (Join-Path $PSScriptRoot 'common.ps1')
& (Join-Path $PSScriptRoot 'local-only.ps1') -Action check
& py -3 -B (Join-Path $PSScriptRoot 'toolkit.py') export --destination $Destination
if ($LASTEXITCODE -ne 0) { throw 'Toolkit export failed.' }
