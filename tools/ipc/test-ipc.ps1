<#
.SYNOPSIS
Compiles and runs focused IPC tests in an isolated temporary deployment.
.DESCRIPTION
Run tools/build/build.bat first to generate TGUI, translations and other assets.
Logs, results and screenshot candidates remain under tmp/ipc-test-*.
Uses the repository screenshot comparator after the DM assertions. Inspect any
new candidates before copying references into code/modules/unit_tests/screenshots.
Use -IncludeHumanoidScreenshots to include the broader all-species visual suite.
#>
[CmdletBinding()]
param(
    [string]$ByondBin,
    [switch]$IncludeHumanoidScreenshots,
    [ValidateRange(30, 3600)]
    [int]$TimeoutSeconds = 300
)

$ErrorActionPreference = 'Stop'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if (-not $ByondBin) {
    $compilerCommand = Get-Command 'dm.exe' -ErrorAction SilentlyContinue
    if ($compilerCommand) {
        $ByondBin = Split-Path -Parent $compilerCommand.Source
    } else {
        $ByondBin = Join-Path ${env:ProgramFiles(x86)} 'BYOND\bin'
    }
}
$compiler = Join-Path $ByondBin 'dm.exe'
$daemon = Join-Path $ByondBin 'dd.exe'
foreach ($executable in @($compiler, $daemon)) {
    if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
        throw "BYOND executable not found: $executable. Pass -ByondBin with the BYOND bin directory."
    }
}

$runName = 'ipc-test-' + [Guid]::NewGuid().ToString('N').Substring(0, 12)
$runDirectory = Join-Path $repoRoot ('tmp\' + $runName)
$wrapperName = $runName + '.test'
$wrapperPath = Join-Path $repoRoot ($wrapperName + '.dme')
$rootArtifacts = @('.dme', '.dmb', '.rsc') | ForEach-Object { Join-Path $repoRoot ($wrapperName + $_) }
New-Item -ItemType Directory -Path $runDirectory | Out-Null
Write-Output "IPC test artifacts: $runDirectory"

Push-Location -LiteralPath $repoRoot
try {
    $baselineTests = @(
        'preference_species', 'species_change_organs', 'species_config_sanity',
        'species_unique_id', 'species_whitelist_check'
    ) | ForEach-Object { '/datum/unit_test/' + $_ }
    if ($IncludeHumanoidScreenshots) {
        $baselineTests += '/datum/unit_test/screenshot_humanoids'
    }
    $ipcTests = Get-ChildItem -LiteralPath 'modular_bandastation\species\code\tests' -Filter 'ipc*.dm' |
        Select-String -Pattern '^(/datum/unit_test/ipc[^/\s]*)/Run\(' |
        ForEach-Object { $_.Matches[0].Groups[1].Value }
    if (-not $ipcTests) {
        throw 'No IPC unit tests found.'
    }
    $focusedTests = @(@($baselineTests) + @($ipcTests) | Sort-Object -Unique)
    $wrapperLines = @('#include "tgstation.dme"') + @($focusedTests | ForEach-Object { 'TEST_FOCUS(' + $_ + ')' })
    [IO.File]::WriteAllLines($wrapperPath, [string[]]$wrapperLines, $utf8NoBom)
    Write-Output "Compiling $($focusedTests.Count) focused tests."
    & $compiler -DCBT -DUNIT_TESTS -DMINIMAL_CENTCOM $wrapperPath 2>&1 |
        Tee-Object -FilePath (Join-Path $runDirectory 'compile.log')
    if ($LASTEXITCODE -ne 0) {
        throw "DM compilation failed. See $runDirectory\compile.log"
    }
    foreach ($extension in @('.dmb', '.rsc')) {
        Move-Item -LiteralPath (Join-Path $repoRoot ($wrapperName + $extension)) -Destination (Join-Path $runDirectory ('ipc.test' + $extension))
    }

    # Match the runtime assets in tools/deploy.sh, with local screenshot references.
    $assetDirectories = @(
        '_maps', 'build\behavior_trees', 'code\datums\greyscale\json_configs',
        'icons', 'sound\runtime', 'strings', 'tgui\public', 'modular_bandastation',
        'code\modules\unit_tests\screenshots'
    )
    foreach ($relativePath in $assetDirectories) {
        $destination = Join-Path $runDirectory $relativePath
        New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $repoRoot $relativePath) -Destination $destination -Recurse
    }
    Get-ChildItem -LiteralPath $repoRoot -Filter '*.dll' -File |
        Copy-Item -Destination $runDirectory
    New-Item -ItemType Directory -Path (Join-Path $runDirectory 'data\spritesheets'), (Join-Path $runDirectory 'config') -Force | Out-Null
    Copy-Item -LiteralPath '_maps\map_jsons\runtimestation_minimal.json' -Destination (Join-Path $runDirectory 'data\next_map.json')
    # Use the configured race list, without loading deployment credentials or services.
    $raceConfig = @(Get-Content -LiteralPath 'config\game_options.txt', 'config\bandastation\bandastation_config.txt' |
        Where-Object { $_ -match '^\s*ROUNDSTART_RACES\s+\S+' })
    [IO.File]::WriteAllLines((Join-Path $runDirectory 'config\config.txt'), [string[]]$raceConfig, $utf8NoBom)
    [IO.File]::WriteAllLines((Join-Path $runDirectory 'config\maps.txt'), [string[]]@('map runtimestation_minimal', 'default', 'endmap'), $utf8NoBom)

    # dd.exe is the console daemon; DreamDaemon.exe is the Windows GUI launcher.
    $server = Start-Process -FilePath $daemon -WorkingDirectory $runDirectory -WindowStyle Hidden -PassThru -ArgumentList 'ipc.test.dmb -trusted -invisible -log console.log -params log-directory=ipc'
    try {
        if (-not $server.WaitForExit($TimeoutSeconds * 1000)) {
            throw "IPC tests exceeded $TimeoutSeconds seconds. See $runDirectory\console.log"
        }
    } finally {
        if (-not $server.HasExited) {
            $server.Kill()
            $server.WaitForExit()
        }
        $server.Dispose()
    }

    $resultsPath = Join-Path $runDirectory 'data\unit_tests.json'
    if (-not (Test-Path -LiteralPath $resultsPath)) {
        throw "The daemon did not produce test results. See $runDirectory\console.log"
    }
    $results = Get-Content -LiteralPath $resultsPath -Raw | ConvertFrom-Json
    $actualTests = @($results.PSObject.Properties.Name)
    $missingTests = @($focusedTests | Where-Object { $_ -notin $actualTests })
    $failedTests = @($results.PSObject.Properties.Value | Where-Object { $_.status -ne 0 })
    foreach ($failedTest in $failedTests) {
        Write-Output ($failedTest.name + ': ' + $failedTest.message)
    }
    Write-Output "$($actualTests.Count - $failedTests.Count)/$($actualTests.Count) DM tests passed. Results: $resultsPath"
    $cleanMarker = Join-Path $runDirectory 'data\logs\ipc\clean_run.lk'
    $cleanShutdown = (Test-Path -LiteralPath $cleanMarker) -and ((Get-Content -LiteralPath $cleanMarker -Raw).Trim() -eq 'Success!')
    $runtimeLog = Join-Path $runDirectory 'data\logs\ipc\runtime.log.json'
    $runtimeErrors = @(Select-String -LiteralPath $runtimeLog -Pattern 'Runtime in|runtime error' -ErrorAction SilentlyContinue)

    $comparisonCache = Join-Path $repoRoot 'tmp\ipc-screenshot-compare'
    New-Item -ItemType Directory -Path $comparisonCache -Force | Out-Null
    Copy-Item -LiteralPath 'tools\screenshot-test-comparison\package.json', 'tools\screenshot-test-comparison\index.js' -Destination $comparisonCache -Force
    & (Join-Path $repoRoot 'tools\bootstrap\javascript.bat') install --cwd $comparisonCache --ignore-scripts
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not install the repository screenshot comparator dependencies.'
    }
    $artifactsPath = Join-Path $runDirectory 'artifacts'
    $screenshotsPath = Join-Path $artifactsPath 'test_artifacts_ipc\screenshots_new'
    New-Item -ItemType Directory -Path $screenshotsPath -Force | Out-Null
    $actualImages = @(Get-ChildItem -LiteralPath (Join-Path $runDirectory 'data\screenshots') -Filter '*.png' -File -ErrorAction SilentlyContinue)
    $newImages = @(Get-ChildItem -LiteralPath (Join-Path $runDirectory 'code\modules\unit_tests\screenshots') -Filter '*.png' -File |
        Where-Object { -not (Test-Path -LiteralPath (Join-Path $repoRoot ('code\modules\unit_tests\screenshots\' + $_.Name))) })
    foreach ($screenshot in @($actualImages) + @($newImages)) {
        Copy-Item -LiteralPath $screenshot.FullName -Destination $screenshotsPath
    }
    & (Join-Path $repoRoot 'tools\bootstrap\javascript.bat') (Join-Path $comparisonCache 'index.js') $artifactsPath (Join-Path $repoRoot 'code\modules\unit_tests\screenshots') (Join-Path $runDirectory 'screenshot-comparisons')
    $screenshotsPassed = $LASTEXITCODE -eq 0
    Write-Output "$($actualImages.Count + $newImages.Count) screenshots compared; passed: $screenshotsPassed. Candidates: $screenshotsPath"
    if ($missingTests.Count -or $failedTests.Count -or -not $cleanShutdown -or $runtimeErrors.Count -or -not $screenshotsPassed) {
        throw "IPC validation failed. Missing tests: $($missingTests -join ', '). Runtime errors: $($runtimeErrors.Count). Clean shutdown: $cleanShutdown. Inspect the preserved artifacts."
    }
} finally {
    # Only these uniquely named, directly contained root artifacts belong to this run.
    foreach ($artifact in $rootArtifacts) {
        $absolutePath = [IO.Path]::GetFullPath($artifact)
        if ((Split-Path -Parent $absolutePath) -ne $repoRoot -or (Split-Path -Leaf $absolutePath) -notlike ($wrapperName + '.*')) {
            throw "Refusing to clean up unexpected path: $absolutePath"
        }
        if (Test-Path -LiteralPath $absolutePath -PathType Leaf) {
            Move-Item -LiteralPath $absolutePath -Destination $runDirectory
        }
    }
    Pop-Location
}
