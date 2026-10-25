[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ByondBin,
    [string]$Python = 'python',
    [string]$RustGDll,
    [ValidatePattern('^[0-9a-fA-F]{64}$')]
    [string]$Sha256 = '51130b5597a992b01c06fa620ec3b45862247f7aa8d5e85285f271d15ac83b24',
    [ValidateRange(1, 20)][int]$Repeat = 1,
    [ValidateRange(15000, 600000)][int]$WaitMs = 15000
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..\..')).Path
$ByondBin = (Resolve-Path -LiteralPath $ByondBin).Path
if (-not $RustGDll) { $RustGDll = Join-Path $repo 'rust_g.dll' }
$dll = (Resolve-Path -LiteralPath $RustGDll).Path
$Sha256 = $Sha256.ToLowerInvariant()
if ((Get-FileHash -LiteralPath $dll -Algorithm SHA256).Hash.ToLowerInvariant() -ne $Sha256) {
    throw 'RustG DLL differs from the expected SHA256. An alternate DLL requires its explicit audited -Sha256.'
}
$executables = @{}
foreach ($exe in @('dm.exe', 'dd.exe')) {
    $path = Join-Path $ByondBin $exe
    $version = [Diagnostics.FileVersionInfo]::GetVersionInfo($path)
    if ($version.FileBuildPart -ne 516 -or $version.FilePrivatePart -ne 1685) { throw 'BYOND 516.1685 is required.' }
    $executables[$exe] = @{ path = $path; version = $version.FileVersion; sha256 = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() }
}
$folder = Join-Path $repo ('tmp\rustg-shutdown-' + [Guid]::NewGuid().ToString('N').Substring(0, 10))
New-Item -ItemType Directory -Path $folder | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding($false)
. (Join-Path $PSScriptRoot "..\native-harness-helpers.ps1")

# Freeze the chosen DLL once; later workspace replacements cannot mix binaries within a series.
$pinnedDll = Join-Path $folder 'rust_g.dll'
Copy-Item -LiteralPath $dll -Destination $pinnedDll
if ((Get-FileHash -LiteralPath $pinnedDll -Algorithm SHA256).Hash.ToLowerInvariant() -ne $Sha256) { throw 'DLL changed while being copied.' }
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'repro.dm.in') -Destination (Join-Path $folder 'repro.dm')
[IO.File]::WriteAllText((Join-Path $folder 'repro.dme'), '#include "repro.dm"', $utf8)
& $Python (Join-Path $PSScriptRoot 'make_fixture.py') (Join-Path $folder 'input.dmi')
if ($LASTEXITCODE -ne 0) { throw 'Fixture creation failed; Python with Pillow is required.' }
$manifest = [ordered]@{
    schema_version = 2; status = 'running'; started = (Get-Date).ToString('o')
    rust_g = @{ source = $dll; expected_sha256 = $Sha256; actual_sha256 = (Get-FileHash -LiteralPath $pinnedDll -Algorithm SHA256).Hash.ToLowerInvariant() }
    executables = $executables; repeat = $Repeat; wait_ms = $WaitMs
    modes = @('control', 'forge', 'cleanup', 'warm'); close_flags = @($false, $true)
    source_sha256 = (Get-FileHash -LiteralPath (Join-Path $folder 'repro.dm') -Algorithm SHA256).Hash.ToLowerInvariant()
    fixture_sha256 = (Get-FileHash -LiteralPath (Join-Path $folder 'input.dmi') -Algorithm SHA256).Hash.ToLowerInvariant()
    validator_sha256 = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'validate_output.py') -Algorithm SHA256).Hash.ToLowerInvariant()
    harness_sha256 = (Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant()
    helpers_sha256 = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot '..\native-harness-helpers.ps1') -Algorithm SHA256).Hash.ToLowerInvariant()
    output_contract = 'Forge JSON error=null,file_path,width=32,height=32; PNG/DMI result dirs=1 frames=1; all RGBA=(255,0,0,255). Warm has three epochs in one process.'
}
Write-ArtifactJson (Join-Path $folder 'manifest.json') $manifest
$results = @(); $processWindows = @{}; $started = Get-Date; $setupFailure = $null
try {
    $compileStarted = Get-Date
    $compile = Start-Process -FilePath $executables['dm.exe'].path -ArgumentList 'repro.dme' -WorkingDirectory $folder -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $folder 'compile.log') -RedirectStandardError (Join-Path $folder 'compile.stderr.log')
    $compilePid = $compile.Id
    $compileTimedOut = -not $compile.WaitForExit(60000)
    if ($compileTimedOut) { $compile.Kill(); $compile.WaitForExit() }
    $compileExit = $compile.ExitCode
    Register-ProcessWindow $processWindows $compilePid $compileStarted (Get-Date)
    $compile.Dispose()
    $manifest.compile = @{ pid = $compilePid; exit_code = $compileExit; timed_out = $compileTimedOut }
    if ($compileTimedOut -or $compileExit -ne 0 -or -not (Test-Path -LiteralPath (Join-Path $folder 'repro.dmb'))) { throw 'Reproduction compilation failed or timed out.' }
    $manifest.dmb_sha256 = (Get-FileHash -LiteralPath (Join-Path $folder 'repro.dmb') -Algorithm SHA256).Hash.ToLowerInvariant()
    Write-ArtifactJson (Join-Path $folder 'manifest.json') $manifest
    foreach ($mode in $manifest.modes) {
        foreach ($close in $manifest.close_flags) {
            foreach ($replay in 1..$Repeat) {
                $run = Join-Path $folder ($mode + '-' + [int]$close + '-' + $replay)
                New-Item -ItemType Directory -Path $run | Out-Null
                Copy-Item -LiteralPath (Join-Path $folder 'repro.dmb'), (Join-Path $folder 'input.dmi') -Destination $run
                if (Test-Path -LiteralPath (Join-Path $folder 'repro.rsc')) { Copy-Item -LiteralPath (Join-Path $folder 'repro.rsc') -Destination $run }
                Copy-Item -LiteralPath $pinnedDll -Destination (Join-Path $run 'rust_g.dll')
                $copiedHash = (Get-FileHash -LiteralPath (Join-Path $run 'rust_g.dll') -Algorithm SHA256).Hash.ToLowerInvariant()
                if ($copiedHash -ne $Sha256) { throw 'Per-process DLL copy differs from its pin.' }
                $arguments = "repro.dmb -trusted -invisible -log console.log -params mode=$mode"
                if ($close) { $arguments += ' -close' }
                $timer = [Diagnostics.Stopwatch]::StartNew(); $launchTime = Get-Date
                $nativePid = $null; $exitCode = $null; $forcedExitCode = $null; $exited = $false; $launchError = $null
                $process = $null; $epochObservations = @()
                try {
                    $process = Start-Process -FilePath $executables['dd.exe'].path -ArgumentList $arguments -WorkingDirectory $run -WindowStyle Hidden -PassThru
                    $nativePid = $process.Id
                    [IO.File]::WriteAllText((Join-Path $run 'host-pid.txt.pending'), [string]$nativePid, $utf8)
                    [IO.File]::Move((Join-Path $run 'host-pid.txt.pending'), (Join-Path $run 'host-pid.txt'))
                    while (-not $process.HasExited -and $timer.ElapsedMilliseconds -lt $WaitMs) {
                        foreach ($epoch in 1..3) {
                            if ($epoch -notin $epochObservations -and (Test-Path -LiteralPath (Join-Path $run "epoch-$epoch.json"))) { $epochObservations += $epoch }
                        }
                        [void]$process.WaitForExit(100)
                    }
                    $exited = $process.HasExited
                    if ($exited) { $exitCode = $process.ExitCode } else { $process.Kill(); $process.WaitForExit(); $forcedExitCode = $process.ExitCode }
                } catch { $launchError = $_.Exception.Message } finally {
                    if ($process) {
                        if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit() }
                        $process.Dispose()
                    }
                }
                $timer.Stop(); $endTime = Get-Date
                if ($null -ne $nativePid) { Register-ProcessWindow $processWindows $nativePid $launchTime $endTime }
                $validationText = @(); $validation = $null; $validationError = $null
                try {
                    if ((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'validate_output.py') -Algorithm SHA256).Hash.ToLowerInvariant() -ne $manifest.validator_sha256) { throw 'Validator changed during the series.' }
                    $validationText = @(& $Python (Join-Path $PSScriptRoot 'validate_output.py') $run $mode 2> (Join-Path $run 'validation.stderr.log'))
                    $validationExit = $LASTEXITCODE
                    $validation = ($validationText -join "`n") | ConvertFrom-Json
                    if ($validationExit -ne 0 -and $validation.valid) { $validationError = "Validator exit $validationExit contradicts its result." }
                } catch { $validationError = $_.Exception.Message }
                [IO.File]::WriteAllText((Join-Path $run 'validation.json'), ($validationText -join "`n"), $utf8)
                $reasons = @()
                if ($launchError) { $reasons += "Daemon launch/wait error: $launchError" }
                if (-not $exited) { $reasons += "Daemon did not exit naturally within $WaitMs ms; it was forcibly stopped." }
                if ($null -eq $exitCode -or $exitCode -ne 0) { $reasons += "Native exit code: $exitCode" }
                if ($validationError -or -not $validation -or -not $validation.valid) { $reasons += "Output/marker validation failed: $validationError" }
                if ($mode -eq 'warm' -and @(1..3 | Where-Object { $_ -notin $epochObservations }).Count) { $reasons += 'Not every warm epoch was observed while the original process handle was alive.' }
                $row = [pscustomobject]@{
                    mode = $mode; close = $close; replay = $replay; run = $run; pid = $nativePid
                    exited = $exited; timedOut = (-not $exited -and $null -eq $launchError); exitCode = $exitCode; forcedExitCode = $forcedExitCode
                    exitCodeHex = $(if ($null -ne $exitCode) { '0x{0:X8}' -f [int32]$exitCode } else { $null })
                    ms = $timer.ElapsedMilliseconds; start = $launchTime; end = $endTime; arguments = $arguments
                    ready = (Test-Path -LiteralPath (Join-Path $run 'ready.marker')); invalid = ($reasons.Count -gt 0)
                    output = (Test-Path -LiteralPath (Join-Path $run 'output.dmi')); validation = $validation; validationError = $validationError
                    observedEpochs = $epochObservations; dll_sha256 = $copiedHash; failureReasons = $reasons; applicationFaults = @()
                }
                $results += $row
                $row | ConvertTo-Json -Depth 8 -Compress
                Write-ArtifactJson (Join-Path $folder 'results.json') @($results)
            }
        }
    }
} catch { $setupFailure = $_.Exception.Message } finally {
    # WER delivery can lag process exit; audit every recorded PID, including timeouts and nonzero exits.
    Start-Sleep -Seconds 5
    $faults = Get-FaultEvidence $started $processWindows
    Write-ArtifactJson (Join-Path $folder 'events.json') @($faults.events)
    Write-ArtifactJson (Join-Path $folder 'event-audit.json') $faults
    foreach ($row in $results) {
        $row.applicationFaults = @($faults.events | Where-Object { $_.pid -eq $row.pid })
        if ($row.applicationFaults.Count) { $row.failureReasons += 'Windows Application Error event matched this process.'; $row.invalid = $true }
    }
    Write-ArtifactJson (Join-Path $folder 'results.json') @($results)
    $manifest.setup_failure = $setupFailure; $manifest.finished = (Get-Date).ToString('o')
    $manifest.event_query_error = $faults.query_error; $manifest.unparsed_daemon_events = @($faults.unparsed_daemon_events).Count
    $manifest.failed_cases = @($results | Where-Object { $_.invalid }).Count
    $manifest.success = -not ($setupFailure -or $manifest.failed_cases -or $faults.events.Count -or $faults.query_error -or $faults.unparsed_daemon_events.Count)
    $manifest.status = if ($manifest.success) { 'passed' } else { 'failed' }
    Write-ArtifactJson (Join-Path $folder 'manifest.json') $manifest
}
Write-Output "ARTIFACTS=$folder"
if ($setupFailure -or $manifest.failed_cases -or $faults.events.Count -or $faults.query_error -or $faults.unparsed_daemon_events.Count) {
    throw "Native failure or incomplete evidence; inspect $folder\manifest.json, results.json and event-audit.json"
}
