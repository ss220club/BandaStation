<#
Compile and run the Lighting lumcount suite in an isolated local deployment.
Run BUILD.cmd first to prepare generated assets and the dependency versions in dependencies.sh.
#>
[CmdletBinding()]
param(
    [string]$ByondBin = (Join-Path ${env:ProgramFiles(x86)} 'BYOND\bin'),
    [ValidateRange(30, 3600)][int]$TimeoutSeconds = 300
)
$ErrorActionPreference = 'Stop'
# Detach only our junction itself: recursive tmp cleanup must never reach checkout assets.
function Remove-TestAssetJunction {
    param([string]$Path, [string]$RunDirectory, [string]$ExpectedTarget)
    $runRoot = [IO.Path]::GetFullPath((Resolve-Path -LiteralPath $RunDirectory).ProviderPath).TrimEnd('\', '/')
    $runPrefix = $runRoot + [IO.Path]::DirectorySeparatorChar
    $linkPath = [IO.Path]::GetFullPath($Path)
    if (-not $linkPath.StartsWith($runPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to unlink a path outside the test run: $linkPath"
    }
    try { $link = Get-Item -LiteralPath $linkPath -Force -ErrorAction Stop }
    catch [System.Management.Automation.ItemNotFoundException] { return }
    if ($link.LinkType -ne 'Junction') { throw "Refusing to unlink a non-junction: $linkPath" }
    $parentPath = Split-Path -Parent $linkPath
    while ($parentPath.StartsWith($runPrefix, [StringComparison]::OrdinalIgnoreCase) -or $parentPath.Equals($runRoot, [StringComparison]::OrdinalIgnoreCase)) {
        if ((Get-Item -LiteralPath $parentPath -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "Refusing to unlink through a reparse-point parent: $parentPath"
        }
        if ($parentPath.Equals($runRoot, [StringComparison]::OrdinalIgnoreCase)) { break }
        $parentPath = Split-Path -Parent $parentPath
    }
    $targets = @($link.Target)
    $expectedPath = [IO.Path]::GetFullPath($ExpectedTarget).TrimEnd('\', '/')
    if ($targets.Count -ne 1 -or -not ([IO.Path]::GetFullPath($targets[0]).TrimEnd('\', '/')).Equals($expectedPath, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to unlink a junction with an unexpected target: $linkPath"
    }
    [IO.Directory]::Delete($linkPath, $false)
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$runName = 'lighting-lumcount-' + [Guid]::NewGuid().ToString('N').Substring(0, 12)
$runDirectory = Join-Path $repoRoot ('tmp\' + $runName)
$wrapper = Join-Path $repoRoot ($runName + '.test.dme')
$compiler = Join-Path $ByondBin 'dm.exe'
$daemon = Join-Path $ByondBin 'dd.exe'
foreach ($executable in @($compiler, $daemon)) {
    if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) { throw "Missing BYOND executable: $executable" }
}
New-Item -ItemType Directory -Path $runDirectory | Out-Null
Write-Output "Lighting lumcount artifacts: $runDirectory"
$assetJunctions = @()
Push-Location -LiteralPath $repoRoot
try {
    $tests = @(Select-String -LiteralPath 'code\modules\unit_tests\lighting_lumcount.dm' -Pattern '^(/datum/unit_test/[^\s(]+)/Run\(' |
        ForEach-Object { $_.Matches[0].Groups[1].Value })
    if (-not $tests.Count) { throw 'No Lighting lumcount tests found.' }
    $tests += '/datum/unit_test/focus_only/invalid_emissives'
    $tests = @($tests | Sort-Object -Unique)
    $lines = @('#include "tgstation.dme"') + @($tests | ForEach-Object { 'TEST_FOCUS(' + $_ + ')' })
    [IO.File]::WriteAllLines($wrapper, [string[]]$lines, $utf8NoBom)
    [IO.File]::WriteAllLines((Join-Path $runDirectory 'focused-tests.txt'), [string[]]$tests, $utf8NoBom)
    & $compiler -DCBT -DUNIT_TESTS -DMINIMAL_CENTCOM $wrapper 2>&1 | Tee-Object -FilePath (Join-Path $runDirectory 'compile.log')
    if ($LASTEXITCODE -ne 0) { throw "DM compilation failed: $runDirectory\compile.log" }
    foreach ($extension in @('.dmb', '.rsc')) {
        Move-Item -LiteralPath ([IO.Path]::ChangeExtension($wrapper, $extension)) -Destination (Join-Path $runDirectory ('lighting.test' + $extension))
    }
    # Junction assets only while the test server runs; logs and binaries stay after unlinking.
    foreach ($relative in @('_maps', 'build\behavior_trees', 'code\datums\greyscale\json_configs', 'icons', 'sound\runtime', 'strings', 'tgui\public', 'modular_bandastation')) {
        $destination = Join-Path $runDirectory $relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        New-Item -ItemType Junction -Path $destination -Target (Join-Path $repoRoot $relative) | Out-Null
        $assetJunctions += [pscustomobject]@{ Path = $destination; Target = (Join-Path $repoRoot $relative) }
    }
    Get-ChildItem -LiteralPath $repoRoot -Filter '*.dll' -File | Copy-Item -Destination $runDirectory
    New-Item -ItemType Directory -Force -Path (Join-Path $runDirectory 'data\spritesheets'), (Join-Path $runDirectory 'config') | Out-Null
    Copy-Item -LiteralPath '_maps\map_jsons\runtimestation_minimal.json' -Destination (Join-Path $runDirectory 'data\next_map.json')
    [IO.File]::WriteAllLines((Join-Path $runDirectory 'config\maps.txt'), [string[]]@('map runtimestation_minimal', 'default', 'endmap'), $utf8NoBom)
    $server = Start-Process -FilePath $daemon -WorkingDirectory $runDirectory -WindowStyle Hidden -PassThru -ArgumentList 'lighting.test.dmb -trusted -invisible -log console.log -params log-directory=lighting-lumcount'
    try {
        if (-not $server.WaitForExit($TimeoutSeconds * 1000)) { throw "Lighting lumcount tests timed out: $runDirectory" }
        $daemonExitCode = $server.ExitCode
    } finally {
        if (-not $server.HasExited) { $server.Kill(); $server.WaitForExit() }
        $server.Dispose()
    }
    $resultsPath = Join-Path $runDirectory 'data\unit_tests.json'
    if (-not (Test-Path -LiteralPath $resultsPath)) { throw "No test results: $runDirectory\console.log" }
    $results = Get-Content -LiteralPath $resultsPath -Raw | ConvertFrom-Json
    $required = @($tests | Where-Object { $_ -notlike '/datum/unit_test/focus_only/*' })
    $missing = @($required | Where-Object { $_ -notin $results.PSObject.Properties.Name })
    $failed = @($results.PSObject.Properties.Value | Where-Object { $_.status -ne 0 })
    $logs = Join-Path $runDirectory 'data\logs\lighting-lumcount'
    $runtimePaths = @((Join-Path $logs 'dd.log'), (Join-Path $logs 'runtime.log.json'), (Join-Path $runDirectory 'console.log'))
    $missingLogs = @($runtimePaths | Where-Object { -not (Test-Path -LiteralPath $_) })
    $runtimeErrors = @(Select-String -LiteralPath @($runtimePaths | Where-Object { Test-Path -LiteralPath $_ }) -Pattern 'Runtime in\b|runtime error\b|uncaught exception\b|Total runtimes:\s*[1-9]|Maximum recursion level reached|Infinite loop suspected|BYOND out of memory')
    $marker = Join-Path $logs 'clean_run.lk'
    $clean = (Test-Path -LiteralPath $marker) -and ((Get-Content -LiteralPath $marker -Raw).Trim() -eq 'Success!')
    foreach ($failure in $failed) { Write-Output ($failure.name + ': ' + $failure.message) }
    foreach ($runtimeError in $runtimeErrors) { Write-Output $runtimeError.ToString() }
    Write-Output "$(@($results.PSObject.Properties).Count - $failed.Count)/$(@($results.PSObject.Properties).Count) test result groups passed. Results: $resultsPath"
    if ($daemonExitCode -ne 0 -or $missing.Count -or $failed.Count -or $missingLogs.Count -or $runtimeErrors.Count -or -not $clean) {
        throw "Lighting lumcount validation failed: exit=$daemonExitCode, missing=$($missing -join ','), failed=$($failed.Count), runtimes=$($runtimeErrors.Count), missing logs=$($missingLogs.Count), clean=$clean."
    }
} finally {
    $cleanupFailures = @()
    try {
        foreach ($junction in $assetJunctions) {
            try {
                Remove-TestAssetJunction -Path $junction.Path -RunDirectory $runDirectory -ExpectedTarget $junction.Target
            } catch { $cleanupFailures += $_.Exception.Message }
        }
        if (Test-Path -LiteralPath $wrapper) { Move-Item -LiteralPath $wrapper -Destination $runDirectory }
    } finally { Pop-Location }
    if ($cleanupFailures.Count) { throw ("Test junction cleanup failed: " + ($cleanupFailures -join '; ')) }
}
