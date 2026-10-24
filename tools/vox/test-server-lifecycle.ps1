<#
.SYNOPSIS
Runs an ordinary minimal-map server through graceful shutdown and same-host VM reboots.
.DESCRIPTION
Does not define UNIT_TESTS or change the production DME/world. Alternate DLLs require
their audited -Sha256. Cases are serial and use fresh data/config directories.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ByondBin,
    [string]$Python = 'python',
    [string]$RustGDll,
    [ValidatePattern('^[0-9a-fA-F]{64}$')]
    [string]$Sha256 = '51130b5597a992b01c06fa620ec3b45862247f7aa8d5e85285f271d15ac83b24',
    [ValidateRange(1, 20)][int]$Repeat = 1,
    [ValidateRange(15, 3600)][int]$TimeoutSeconds = 600
)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$ByondBin = (Resolve-Path -LiteralPath $ByondBin).Path
if (-not $RustGDll) { $RustGDll = Join-Path $repo 'rust_g.dll' }
$dll = (Resolve-Path -LiteralPath $RustGDll).Path
$Sha256 = $Sha256.ToLowerInvariant()
if ((Get-FileHash -LiteralPath $dll -Algorithm SHA256).Hash.ToLowerInvariant() -ne $Sha256) { throw 'RustG DLL differs from its expected -Sha256.' }
. (Join-Path $PSScriptRoot 'native-harness-helpers.ps1')
$utf8 = New-Object System.Text.UTF8Encoding($false)
$executables = @{}
foreach ($exe in @('dm.exe', 'dd.exe')) {
    $path = Join-Path $ByondBin $exe
    $version = [Diagnostics.FileVersionInfo]::GetVersionInfo($path)
    if ($version.FileBuildPart -ne 516 -or $version.FilePrivatePart -ne 1685) { throw 'BYOND 516.1685 is required.' }
    $executables[$exe] = @{ path = $path; version = $version.FileVersion; sha256 = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() }
}
$name = 'server-lifecycle-' + [Guid]::NewGuid().ToString('N').Substring(0, 12)
$folder = Join-Path $repo ('tmp\' + $name)
New-Item -ItemType Directory -Path $folder | Out-Null
$pinnedDll = Join-Path $folder 'rust_g.dll'
Copy-Item -LiteralPath $dll -Destination $pinnedDll
if ((Get-FileHash -LiteralPath $pinnedDll -Algorithm SHA256).Hash.ToLowerInvariant() -ne $Sha256) { throw 'DLL changed during snapshot.' }
$otherDllSnapshot = Join-Path $folder 'runtime-dlls'
New-Item -ItemType Directory -Path $otherDllSnapshot | Out-Null
$otherDllHashes = @{}
foreach ($runtimeDll in Get-ChildItem -LiteralPath $repo -Filter '*.dll' -File | Where-Object { $_.Name -ne 'rust_g.dll' }) {
    Copy-Item -LiteralPath $runtimeDll.FullName -Destination $otherDllSnapshot
    $otherDllHashes[$runtimeDll.Name] = (Get-FileHash -LiteralPath (Join-Path $otherDllSnapshot $runtimeDll.Name) -Algorithm SHA256).Hash.ToLowerInvariant()
}
& $Python (Join-Path $PSScriptRoot 'rustg-shutdown-repro\make_fixture.py') (Join-Path $folder 'lifecycle-input.dmi')
if ($LASTEXITCODE -ne 0) { throw 'Could not generate the native health input.' }
$wrapperName = $name + '.lifecycle'
$wrapperPath = Join-Path $repo ($wrapperName + '.dme')
$wrapper = @('#define LIFECYCLE_HARNESS', '#include "tgstation.dme"', '#include "tools/vox/server-lifecycle-fixture.dm"', '#include "tools/vox/server-lifecycle-space-area-fixture.dm"')
[IO.File]::WriteAllLines($wrapperPath, [string[]]$wrapper, $utf8)
$manifest = [ordered]@{
    schema_version = 1; status = 'running'; unit_tests = $false; repeat = $Repeat; timeout_seconds = $TimeoutSeconds
    requested_port = 0; visibility = 0; hub = ''; sql_enabled = $false
    rust_g = @{ source = $dll; expected_sha256 = $Sha256; actual_sha256 = (Get-FileHash -LiteralPath $pinnedDll -Algorithm SHA256).Hash.ToLowerInvariant() }
    executables = $executables; modes = @('shutdown', 'warm'); close_flags = @($false, $true)
    other_runtime_dll_sha256 = $otherDllHashes
    fixture_sha256 = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'server-lifecycle-fixture.dm') -Algorithm SHA256).Hash.ToLowerInvariant()
    mapping_fixture_sha256 = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'server-lifecycle-space-area-fixture.dm') -Algorithm SHA256).Hash.ToLowerInvariant()
    input_sha256 = (Get-FileHash -LiteralPath (Join-Path $folder 'lifecycle-input.dmi') -Algorithm SHA256).Hash.ToLowerInvariant()
    harness_sha256 = (Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant()
    helpers_sha256 = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'native-harness-helpers.ps1') -Algorithm SHA256).Hash.ToLowerInvariant()
    validator_sha256 = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'validate-server-lifecycle.py') -Algorithm SHA256).Hash.ToLowerInvariant()
    forge_validator_sha256 = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'rustg-shutdown-repro\validate_output.py') -Algorithm SHA256).Hash.ToLowerInvariant()
    pid_proof = 'One dd.exe Process handle remains alive while all epoch JSON markers carrying its parent-issued PID are observed.'
    shutdown_contract = 'Master.Shutdown once; shutdown_logging once; builtin marker; qdel(world). First two warm epochs instead call normal world.Reboot, which owns its shutdown chain.'
}
Write-ArtifactJson (Join-Path $folder 'manifest.json') $manifest
$results = @(); $processWindows = @{}; $started = Get-Date; $setupFailure = $null
try {
    $compileStarted = Get-Date
    $compile = Start-Process -FilePath $executables['dm.exe'].path -ArgumentList "-DCBT -DMINIMAL_CENTCOM $wrapperName.dme" -WorkingDirectory $repo -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $folder 'compile.log') -RedirectStandardError (Join-Path $folder 'compile.stderr.log')
    $compilePid = $compile.Id
    $compileTimedOut = -not $compile.WaitForExit(180000)
    if ($compileTimedOut) { $compile.Kill(); $compile.WaitForExit() }
    $compileExit = $compile.ExitCode
    Register-ProcessWindow $processWindows $compilePid $compileStarted (Get-Date)
    $compile.Dispose()
    $manifest.compile = @{ pid = $compilePid; exit_code = $compileExit; timed_out = $compileTimedOut; flags = '-DCBT -DMINIMAL_CENTCOM, no UNIT_TESTS' }
    if ($compileTimedOut -or $compileExit -ne 0) { throw 'Ordinary-server compilation failed or timed out.' }
    foreach ($extension in @('.dmb', '.rsc')) {
        $artifact = Join-Path $repo ($wrapperName + $extension)
        if (-not (Test-Path -LiteralPath $artifact -PathType Leaf)) { throw "Missing compiler artifact: $artifact" }
        Copy-Item -LiteralPath $artifact -Destination (Join-Path $folder ('lifecycle' + $extension))
    }
    $manifest.dmb_sha256 = (Get-FileHash -LiteralPath (Join-Path $folder 'lifecycle.dmb') -Algorithm SHA256).Hash.ToLowerInvariant()
    $manifest.rsc_sha256 = (Get-FileHash -LiteralPath (Join-Path $folder 'lifecycle.rsc') -Algorithm SHA256).Hash.ToLowerInvariant()
    foreach ($scenario in $manifest.modes) {
        foreach ($close in $manifest.close_flags) {
            foreach ($replay in 1..$Repeat) {
                $run = Join-Path $folder ($scenario + '-' + [int]$close + '-' + $replay)
                New-Item -ItemType Directory -Path $run, (Join-Path $run 'config'), (Join-Path $run 'data\spritesheets') -Force | Out-Null
                Copy-Item -LiteralPath (Join-Path $folder 'lifecycle.dmb'), (Join-Path $folder 'lifecycle.rsc') -Destination $run
                Copy-Item -LiteralPath $pinnedDll -Destination (Join-Path $run 'rust_g.dll')
                $runRustHash = (Get-FileHash -LiteralPath (Join-Path $run 'rust_g.dll') -Algorithm SHA256).Hash.ToLowerInvariant()
                if ($runRustHash -ne $Sha256) { throw 'Per-process RustG copy differs from its pin.' }
                $runtimeHashes = @{}
                foreach ($runtimeDll in Get-ChildItem -LiteralPath $otherDllSnapshot -Filter '*.dll' -File) {
                    Copy-Item -LiteralPath $runtimeDll.FullName -Destination $run
                    $runtimeHashes[$runtimeDll.Name] = (Get-FileHash -LiteralPath (Join-Path $run $runtimeDll.Name) -Algorithm SHA256).Hash.ToLowerInvariant()
                    if ($runtimeHashes[$runtimeDll.Name] -ne $otherDllHashes[$runtimeDll.Name]) { throw 'A supporting runtime DLL changed during deployment.' }
                }
                foreach ($relative in @('_maps', 'build\behavior_trees', 'code\datums\greyscale\json_configs', 'icons', 'sound\runtime', 'strings', 'tgui\public', 'modular_bandastation')) {
                    $destination = [IO.Path]::GetFullPath((Join-Path $run $relative))
                    if (-not $destination.StartsWith([IO.Path]::GetFullPath($run) + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Asset junction escaped the isolated run.' }
                    New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
                    New-Item -ItemType Junction -Path $destination -Target (Join-Path $repo $relative) | Out-Null
                }
                Copy-Item -LiteralPath (Join-Path $repo '_maps\map_jsons\runtimestation_minimal.json') -Destination (Join-Path $run 'data\next_map.json')
                Copy-Item -LiteralPath (Join-Path $folder 'lifecycle-input.dmi') -Destination (Join-Path $run 'data\lifecycle-input.dmi')
                $raceConfig = @(Get-Content -LiteralPath (Join-Path $repo 'config\game_options.txt'), (Join-Path $repo 'config\bandastation\bandastation_config.txt') | Where-Object { $_ -match '^\s*ROUNDSTART_RACES\s+\S+' })
                $configuration = @('RESUME_AFTER_INITIALIZATIONS 1', 'LOBBY_COUNTDOWN 3600') + $raceConfig
                [IO.File]::WriteAllLines((Join-Path $run 'config\config.txt'), [string[]]$configuration, $utf8)
                [IO.File]::WriteAllText((Join-Path $run 'config\dbconfig.txt'), '# SQL_ENABLED deliberately absent; no database credentials are deployed.', $utf8)
                [IO.File]::WriteAllLines((Join-Path $run 'config\maps.txt'), [string[]]@('map runtimestation_minimal', 'default', 'endmap'), $utf8)
                [IO.File]::WriteAllText((Join-Path $run 'data\lifecycle-nonce.txt'), [Guid]::NewGuid().ToString('N'), $utf8)
                # Keep the normal per-world timestamped log directories so warm epochs cannot overwrite earlier evidence.
                $arguments = "lifecycle.dmb 0 -trusted -invisible -log console.log -params lifecycle_mode=$scenario"
                if ($close) { $arguments += ' -close' }
                $timer = [Diagnostics.Stopwatch]::StartNew(); $launchTime = Get-Date
                $process = $null; $nativePid = $null; $exitCode = $null; $forcedExitCode = $null; $exited = $false; $launchError = $null; $observedEpochs = @()
                try {
                    $process = Start-Process -FilePath $executables['dd.exe'].path -ArgumentList $arguments -WorkingDirectory $run -WindowStyle Hidden -PassThru
                    $nativePid = $process.Id
                    [IO.File]::WriteAllText((Join-Path $run 'data\lifecycle-host-pid.txt'), [string]$nativePid, $utf8)
                    while (-not $process.HasExited -and $timer.Elapsed.TotalSeconds -lt $TimeoutSeconds) {
                        foreach ($epoch in 1..3) {
                            if ($epoch -notin $observedEpochs -and (Test-Path -LiteralPath (Join-Path $run "data\lifecycle-epoch-$epoch.json"))) { $observedEpochs += $epoch }
                        }
                        [void]$process.WaitForExit(100)
                    }
                    $exited = $process.HasExited
                    if ($exited) { $exitCode = $process.ExitCode } else { $process.Kill(); $process.WaitForExit(); $forcedExitCode = $process.ExitCode }
                } catch { $launchError = $_.Exception.Message } finally {
                    if ($process) { if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit() }; $process.Dispose() }
                }
                $timer.Stop(); $endTime = Get-Date
                if ($null -ne $nativePid) { Register-ProcessWindow $processWindows $nativePid $launchTime $endTime }
                $validation = $null; $validationError = $null; $validationText = @()
                try {
                    if ((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'validate-server-lifecycle.py') -Algorithm SHA256).Hash.ToLowerInvariant() -ne $manifest.validator_sha256 -or (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'rustg-shutdown-repro\validate_output.py') -Algorithm SHA256).Hash.ToLowerInvariant() -ne $manifest.forge_validator_sha256) { throw 'Validator changed during the series.' }
                    $validationText = @(& $Python (Join-Path $PSScriptRoot 'validate-server-lifecycle.py') $run $scenario 2> (Join-Path $run 'validation.stderr.log'))
                    $validationExit = $LASTEXITCODE
                    $validation = ($validationText -join "`n") | ConvertFrom-Json
                    if ($validationExit -ne 0 -and $validation.valid) { $validationError = 'Validator exit contradicts its result.' }
                } catch { $validationError = $_.Exception.Message }
                [IO.File]::WriteAllText((Join-Path $run 'validation.json'), ($validationText -join "`n"), $utf8)
                $reasons = @()
                if ($launchError) { $reasons += "Daemon launch/wait error: $launchError" }
                if (-not $exited) { $reasons += "Timeout after $TimeoutSeconds seconds; process was forcibly stopped." }
                if ($null -eq $exitCode -or $exitCode -ne 0) { $reasons += "Native exit code: $exitCode" }
                if ($validationError -or -not $validation -or -not $validation.valid) { $reasons += "Lifecycle validation failed: $validationError $($validation.errors -join '; ')" }
                $expectedEpochs = if ($scenario -eq 'warm') { 3 } else { 1 }
                if (@(1..$expectedEpochs | Where-Object { $_ -notin $observedEpochs }).Count) { $reasons += 'Epoch markers were not all observed while the original process handle was alive.' }
                $row = [pscustomobject]@{
                    scenario = $scenario; close = $close; replay = $replay; run = $run; pid = $nativePid; arguments = $arguments
                    start = $launchTime; end = $endTime; ms = $timer.ElapsedMilliseconds; exited = $exited
                    timedOut = (-not $exited -and $null -eq $launchError); exitCode = $exitCode; forcedExitCode = $forcedExitCode
                    exitCodeHex = $(if ($null -ne $exitCode) { '0x{0:X8}' -f [int32]$exitCode } else { $null })
                    observedEpochs = $observedEpochs; validation = $validation; failureReasons = $reasons; invalid = ($reasons.Count -gt 0)
                    runtime_dll_sha256 = $runtimeHashes; rust_g_sha256 = $runRustHash; applicationFaults = @()
                }
                $results += $row; $row | ConvertTo-Json -Depth 10 -Compress
                Write-ArtifactJson (Join-Path $folder 'results.json') @($results)
            }
        }
    }
} catch { $setupFailure = $_.Exception.Message } finally {
    Start-Sleep -Seconds 5
    $faults = Get-FaultEvidence $started $processWindows
    Write-ArtifactJson (Join-Path $folder 'events.json') @($faults.events)
    Write-ArtifactJson (Join-Path $folder 'event-audit.json') $faults
    foreach ($row in $results) {
        $row.applicationFaults = @($faults.events | Where-Object { $_.pid -eq $row.pid })
        if ($row.applicationFaults.Count) { $row.failureReasons += 'Windows Application Error event matched this process.'; $row.invalid = $true }
    }
    Write-ArtifactJson (Join-Path $folder 'results.json') @($results)
    $manifest.finished = (Get-Date).ToString('o'); $manifest.setup_failure = $setupFailure
    $manifest.failed_cases = @($results | Where-Object { $_.invalid }).Count; $manifest.event_query_error = $faults.query_error
    $manifest.unparsed_daemon_events = @($faults.unparsed_daemon_events).Count
    $manifest.success = -not ($setupFailure -or $manifest.failed_cases -or $faults.events.Count -or $faults.query_error -or $faults.unparsed_daemon_events.Count)
    $manifest.status = if ($manifest.success) { 'passed' } else { 'failed' }
    Write-ArtifactJson (Join-Path $folder 'manifest.json') $manifest
    # Only move artifacts created for this exact wrapper; never recursively move/delete deployment assets.
    foreach ($extension in @('.dme', '.dmb', '.rsc')) {
        $artifact = [IO.Path]::GetFullPath((Join-Path $repo ($wrapperName + $extension)))
        if ((Split-Path -Parent $artifact) -ne $repo -or (Split-Path -Leaf $artifact) -notlike ($wrapperName + '.*')) { throw 'Unsafe wrapper artifact path.' }
        if (Test-Path -LiteralPath $artifact -PathType Leaf) { Move-Item -LiteralPath $artifact -Destination $folder }
    }
}
Write-Output "ARTIFACTS=$folder"
if ($setupFailure -or $manifest.failed_cases -or $faults.events.Count -or $faults.query_error -or $faults.unparsed_daemon_events.Count) {
    throw "Ordinary-server lifecycle validation failed or evidence is incomplete; inspect $folder"
}
