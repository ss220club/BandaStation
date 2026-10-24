param([switch]$Repair, [switch]$ConfigOnly, [string]$BrowserSeed, [string]$RipgrepSeed)
$ErrorActionPreference = 'Stop'
$setupArguments = @('-3','-B',(Join-Path $PSScriptRoot 'setup-tools.py'))
if ($Repair) { $setupArguments += '--repair' }
if ($ConfigOnly) { $setupArguments += '--config-only' }
if ($BrowserSeed) { $setupArguments += @('--browser-seed',$BrowserSeed) }
if ($RipgrepSeed) { $setupArguments += @('--ripgrep-seed',$RipgrepSeed) }
& py @setupArguments
if ($LASTEXITCODE -ne 0) { throw 'Agent runtime/config setup failed.' }
