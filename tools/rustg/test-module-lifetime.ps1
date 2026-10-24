<#
.SYNOPSIS
Proves whether RustG remains mapped after the host releases its loader reference.
.DESCRIPTION
Runs fresh x86 native hosts for both byond_fn macro arms. The official control
must unload; a patched DLL must remain mapped and callable. This test does not
pin the module itself or call an export after an unsuccessful mapping query.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$LibraryPath,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Pinned', 'Unloaded')]
    [string]$ExpectedState,
    [ValidatePattern('^[0-9a-fA-F]{64}$')]
    [string]$ExpectedSha256,
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'This probe requires Windows and the .NET Framework x86 compiler.'
}
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$library = (Resolve-Path -LiteralPath $LibraryPath).Path
if (-not $ExpectedSha256) {
    if ($ExpectedState -eq 'Pinned') {
        throw 'Pinned mode requires -ExpectedSha256 from the patched DLL build manifest.'
    }
    $ExpectedSha256 = '51130b5597a992b01c06fa620ec3b45862247f7aa8d5e85285f271d15ac83b24'
}
$actualSha256 = (Get-FileHash -LiteralPath $library -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualSha256 -ne $ExpectedSha256.ToLowerInvariant()) {
    throw "DLL SHA256 mismatch: expected $ExpectedSha256, got $actualSha256."
}
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe'
if (-not (Test-Path -LiteralPath $compiler -PathType Leaf)) {
    throw "The .NET Framework compiler was not found: $compiler"
}
if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $repoRoot ('tmp\rustg-lifetime-' + [Guid]::NewGuid().ToString('N').Substring(0, 12))
}
if (Test-Path -LiteralPath $OutputDirectory) {
    throw 'OutputDirectory must be new so previous probe artifacts cannot be overwritten.'
}
$output = (New-Item -ItemType Directory -Path $OutputDirectory).FullName
$probe = Join-Path $output 'ModuleLifetimeProbe.exe'
$source = Join-Path $PSScriptRoot 'ModuleLifetimeProbe.cs'
& $compiler /nologo /target:exe /platform:x86 "/out:$probe" $source
if ($LASTEXITCODE -ne 0) { throw "The x86 probe did not compile; artifacts: $output" }

$reports = @()
foreach ($firstExport in @('get_version', 'file_exists')) {
    $caseDirectory = (New-Item -ItemType Directory -Path (Join-Path $output $firstExport)).FullName
    $caseLibrary = Join-Path $caseDirectory 'rust_g.dll'
    Copy-Item -LiteralPath $library -Destination $caseLibrary
    $reportPath = Join-Path $caseDirectory 'result.json'
    Push-Location -LiteralPath $caseDirectory
    try {
        & $probe $caseLibrary $ExpectedState $firstExport $reportPath
        $probeExitCode = $LASTEXITCODE
    }
    finally { Pop-Location }
    if ($probeExitCode -ne 0) { throw "The $firstExport probe failed with exit code $probeExitCode; inspect $reportPath" }
    $report = Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json
    if (-not $report.passed -or $report.processBits -ne 32 -or $report.sha256 -ne $actualSha256) {
        throw "Invalid or mismatched $firstExport probe evidence: $reportPath"
    }
    $reports += $report
}
if ($reports[0].processId -eq $reports[1].processId) {
    throw 'The two macro-arm probes unexpectedly used the same process.'
}
$summary = [ordered]@{
    expectedState = $ExpectedState
    sha256 = $actualSha256
    passed = $true
    cases = $reports
}
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $output 'summary.json'), ($summary | ConvertTo-Json -Depth 6) + "`n", $utf8NoBom)
Write-Host "Module lifetime probe passed; evidence: $output"
