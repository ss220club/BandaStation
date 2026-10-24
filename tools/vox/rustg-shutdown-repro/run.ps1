param([Parameter(Mandatory)][string]$ByondBin, [string]$Python='python', [ValidateRange(1,3)][int]$Repeat=1, [int]$WaitMs=15000)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$dll = Join-Path $repo 'rust_g.dll'
if ((Get-FileHash -LiteralPath $dll -Algorithm SHA256).Hash -ne '51130b5597a992b01c06fa620ec3b45862247f7aa8d5e85285f271d15ac83b24') { throw 'Unexpected DLL; this reproduction pins the audited official asset.' }
$folder = Join-Path $repo ('tmp\rustg-shutdown-' + [Guid]::NewGuid().ToString('N').Substring(0,10))
New-Item -ItemType Directory -Path $folder | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'repro.dm') -Destination $folder
Set-Content -LiteralPath (Join-Path $folder 'repro.dme') -Value '#include "repro.dm"' -Encoding ASCII
& $Python (Join-Path $PSScriptRoot 'make_fixture.py') (Join-Path $folder 'input.dmi')
if ($LASTEXITCODE -ne 0) { throw 'Fixture creation failed; Python with Pillow is required.' }
foreach ($exe in @('dm.exe','dd.exe')) { $v = [Diagnostics.FileVersionInfo]::GetVersionInfo((Join-Path $ByondBin $exe)); if ($v.FileBuildPart -ne 516 -or $v.FilePrivatePart -ne 1685) { throw 'This reproduction requires BYOND 516.1685.' } }
$compile = Start-Process -FilePath (Join-Path $ByondBin 'dm.exe') -ArgumentList 'repro.dme' -WorkingDirectory $folder -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput (Join-Path $folder 'compile.log')
if ($compile.ExitCode -ne 0) { throw "Compilation failed: $folder" }
$results = @(); $started = Get-Date
foreach ($mode in @('control','forge','cleanup')) {
    foreach ($close in @($false,$true)) {
        foreach ($replay in 1..$Repeat) {
            $run = Join-Path $folder ($mode + '-' + [int]$close + '-' + $replay)
            New-Item -ItemType Directory -Path $run | Out-Null
            Copy-Item -LiteralPath (Join-Path $folder 'repro.dmb'), (Join-Path $folder 'input.dmi'), $dll -Destination $run
            $arguments = "repro.dmb -trusted -invisible -log console.log -params mode=$mode"
            if ($close) { $arguments += ' -close' }
            $timer = [Diagnostics.Stopwatch]::StartNew()
            $process = Start-Process -FilePath (Join-Path $ByondBin 'dd.exe') -ArgumentList $arguments -WorkingDirectory $run -WindowStyle Hidden -PassThru
            $exited = $process.WaitForExit($WaitMs); $exitCode = $null
            if ($exited) { $exitCode = $process.ExitCode } else { Stop-Process -Id $process.Id -Force }
            $timer.Stop()
            $row = [pscustomobject]@{ mode=$mode; close=$close; replay=$replay; pid=$process.Id; exited=$exited; exitCode=$exitCode; ms=$timer.ElapsedMilliseconds; ready=(Test-Path (Join-Path $run 'ready.marker')); invalid=(Test-Path (Join-Path $run 'invalid.marker')); output=(Test-Path (Join-Path $run 'output.dmi')) }
            if (($mode -eq 'control') -eq $row.output) { $row.invalid = $true }
            $results += $row; $row | ConvertTo-Json -Compress
            $results | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $folder 'results.json') -Encoding UTF8
        }
    }
}
$pids = @{}; $results | ForEach-Object { $pids[$_.pid] = $true }
$events = @(Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$started} -ErrorAction SilentlyContinue | Where-Object { $pids.ContainsKey([Convert]::ToInt32([string]$_.Properties[8].Value,16)) } | ForEach-Object { [pscustomobject]@{ time=$_.TimeCreated; message=$_.Message; xml=$_.ToXml() } })
ConvertTo-Json -InputObject @($events) -Depth 4 | Set-Content -LiteralPath (Join-Path $folder 'events.json') -Encoding UTF8
Write-Output "ARTIFACTS=$folder"
if ($events.Count -or @($results | Where-Object { !$_.exited -or $_.exitCode -ne 0 -or !$_.ready -or $_.invalid }).Count) { throw "Native failure recorded; inspect $folder\results.json and events.json" }
