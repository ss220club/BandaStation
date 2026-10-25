param(
    [string]$ByondBin = 'C:\Program Files (x86)\BYOND\bin'
)

$ErrorActionPreference = 'Stop'
$sourceRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$compiler = Join-Path $ByondBin 'dm.exe'
$daemon = Join-Path $ByondBin 'dd.exe'
if (!(Test-Path -LiteralPath $compiler) -or !(Test-Path -LiteralPath $daemon)) {
    throw 'BYOND not found. Pass -ByondBin with the installed BYOND bin directory.'
}

$testTypes = @(Get-ChildItem -LiteralPath (Join-Path $sourceRoot 'modular_bandastation/sierra_background/tests') -Filter '*.dm' |
    ForEach-Object {
        $sourceText = Get-Content -LiteralPath $_.FullName -Raw
        [regex]::Matches($sourceText, '(?m)^/datum/unit_test/(sierra_background_[a-z0-9_]+)/Run\(') |
            ForEach-Object { $_.Groups[1].Value }
    } | Sort-Object -Unique)
if (!$testTypes.Count) {
    throw 'No Sierra background tests found.'
}
$nativeTestTypes = @(
    'preferences_implement_everything',
    'preferences_valid_savefile_key',
    'preferences_valid_main_feature_name',
    'preferences_should_generate_icons_sanity',
    'preference_species',
    'language_species_swap_simple',
    'language_species_swap_complex',
    'language_species_change_other_known',
    'language_mind_transfer',
    'language_mind_swap',
    'language_key_conflicts'
)

$wrapperName = 'sierra-background.test'
$wrapper = Join-Path $sourceRoot ($wrapperName + '.dme')
$lines = @(
    '#define UNIT_TESTS',
    '#define CIBUILDING',
    '#define CBT',
    '#define RUST_G "./rust_g.dll"',
    '#define RUST_UTILS "./rust_utils.dll"',
    '#include "tgstation.dme"'
)
$lines += @($testTypes) + @($nativeTestTypes) | ForEach-Object { 'TEST_FOCUS(/datum/unit_test/' + $_ + ')' }
$lines += @('/world', "`tloop_checks = 1")
Set-Content -LiteralPath $wrapper -Value $lines -Encoding utf8NoBOM

Push-Location $sourceRoot
try {
    & $compiler ($wrapperName + '.dme')
    if ($LASTEXITCODE -ne 0) { throw 'Sierra background test compilation failed.' }
    $logDirectory = 'sierra-background-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
    & $daemon ($wrapperName + '.dmb') -close -trusted -verbose -params ('log-directory=' + $logDirectory)
    if ($LASTEXITCODE -ne 0) { throw ('Sierra background test server exited with code ' + $LASTEXITCODE + '.') }
    $logRoot = Join-Path $sourceRoot ('data/logs/' + $logDirectory)
    $daemonLog = Join-Path $logRoot 'dd.log'
    if (!(Test-Path -LiteralPath $daemonLog)) {
        throw ('Test server log is missing: ' + $daemonLog)
    }
    $runtimeErrors = @(Select-String -LiteralPath $daemonLog -Pattern '^runtime error:')
    if ($runtimeErrors.Count) {
        throw ('Sierra background test server reported ' + $runtimeErrors.Count + ' runtime errors. Inspect ' + $daemonLog + '.')
    }
    if (!(Test-Path -LiteralPath (Join-Path $logRoot 'clean_run.lk'))) {
        throw ('Sierra background tests failed. Inspect ' + $logRoot + '/tests.log and runtime.log.json.')
    }
    $testResults = Get-Content -LiteralPath 'data/unit_tests.json' -Raw | ConvertFrom-Json
    foreach ($testType in @($testTypes) + @($nativeTestTypes)) {
        $testResult = $testResults.PSObject.Properties['/datum/unit_test/' + $testType]
        if (!$testResult -or $testResult.Value.status -ne 0) {
            throw ('Expected successful result is missing for /datum/unit_test/' + $testType)
        }
    }
    Write-Output ('Passed ' + $testTypes.Count + ' Sierra background groups and ' + $nativeTestTypes.Count + ' native preference/language groups. Logs: ' + $logRoot)
} finally {
    Pop-Location
}
