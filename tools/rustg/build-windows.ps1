<#
.SYNOPSIS
Builds the pinned Windows rust-g lifetime fix in a fresh source directory.
.DESCRIPTION
Requires an already installed Rust 1.93.1 toolchain, i686-pc-windows-msvc target
and MSVC build tools. Does not install tools or replace the running server DLL.
#>
[CmdletBinding()]
param([string]$OutputDirectory)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$revision = '7ba42e2cb84c0fe28862b830d95fa095933f86f4'
$upstream = 'https://github.com/tgstation/rust-g.git'
$target = 'i686-pc-windows-msvc'
$patch = Join-Path $PSScriptRoot 'windows-lifetime.patch'
$git = (Get-Command git -ErrorAction Stop).Source

function Invoke-Checked([string]$Program, [string[]]$Arguments) {
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program exited with $LASTEXITCODE" }
}
function Get-Sha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

if (-not (Test-Path -LiteralPath $patch -PathType Leaf)) { throw "Missing patch: $patch" }
foreach ($name in @('RUSTFLAGS', 'CARGO_ENCODED_RUSTFLAGS', 'CARGO_BUILD_RUSTFLAGS', 'CARGO_TARGET_I686_PC_WINDOWS_MSVC_RUSTFLAGS', 'CARGO_TARGET_DIR')) {
    if ([Environment]::GetEnvironmentVariable($name)) { throw "Unset $name to preserve the pinned build recipe." }
}
$cargo = (Get-Command cargo -ErrorAction Stop).Source
$rustc = (Get-Command rustc -ErrorAction Stop).Source
$buildRoot = Join-Path $repo ('tmp\rustg-build-' + [Guid]::NewGuid().ToString('N').Substring(0, 12))
$source = Join-Path $buildRoot 'source'
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $buildRoot 'output' }
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $OutputDirectory) { throw "Output directory must be new: $OutputDirectory" }
New-Item -ItemType Directory -Path $source -Force | Out-Null
$patchSnapshot = Join-Path $buildRoot 'windows-lifetime.patch'
Copy-Item -LiteralPath $patch -Destination $patchSnapshot
$patch = $patchSnapshot
$previousAutoInstall = $env:RUSTUP_AUTO_INSTALL
$env:RUSTUP_AUTO_INSTALL = '0'
try {
    $rustVersion = (Invoke-Checked $rustc @('+1.93.1', '--version', '--verbose')) -join "`n"
    $cargoVersion = (Invoke-Checked $cargo @('+1.93.1', '--version')) -join "`n"
    if ($rustVersion -notmatch '(?m)^release: 1\.93\.1\r?$') { throw 'Expected Rust 1.93.1.' }
    $gitVersion = (Invoke-Checked $git @('--version')) -join "`n"
    Invoke-Checked $git @('init', '--quiet', $source)
    Invoke-Checked $git @('-C', $source, 'config', 'core.autocrlf', 'false')
    Invoke-Checked $git @('-C', $source, 'remote', 'add', 'origin', $upstream)
    Invoke-Checked $git @('-C', $source, 'fetch', '--no-tags', '--depth', '1', 'origin', $revision)
    Invoke-Checked $git @('-C', $source, 'checkout', '--quiet', '--detach', 'FETCH_HEAD')
    $actual = (Invoke-Checked $git @('-C', $source, 'rev-parse', 'HEAD')).Trim()
    if ($actual -ne $revision) { throw "Unexpected source revision: $actual" }
    Invoke-Checked $git @('-C', $source, 'apply', '--check', $patch)
    Invoke-Checked $git @('-C', $source, 'apply', $patch)
    Push-Location -LiteralPath $source
    try {
        Invoke-Checked $cargo @('+1.93.1', 'build', '--locked', '--release', '--target', $target)
    } finally { Pop-Location }

    $files = [ordered]@{
        'rust_g.dll' = Join-Path $source "target\$target\release\rust_g.dll"
        'rust_g.pdb' = Join-Path $source "target\$target\release\rust_g.pdb"
        'rust_g.dm' = Join-Path $source 'target\rust_g.dm'
        'LICENSE.rust-g.txt' = Join-Path $source 'LICENSE'
        'windows-lifetime.patch' = $patch
    }
    foreach ($inputPath in $files.Values) {
        if (-not (Test-Path -LiteralPath $inputPath -PathType Leaf)) { throw "Missing build output: $inputPath" }
    }
    New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
    $hashes = [ordered]@{}
    foreach ($name in $files.Keys) {
        $destination = Join-Path $OutputDirectory $name
        Copy-Item -LiteralPath $files[$name] -Destination $destination
        $hashes[$name] = [ordered]@{ sha256 = Get-Sha256 $destination; bytes = (Get-Item -LiteralPath $destination).Length }
    }
    $manifest = [ordered]@{
        schema_version = 1
        upstream = [ordered]@{ repository = $upstream; revision = $revision; version = '7.0.0'; cargo_lock_sha256 = Get-Sha256 (Join-Path $source 'Cargo.lock') }
        patch = [ordered]@{ file = 'windows-lifetime.patch'; sha256 = Get-Sha256 $patch }
        build = [ordered]@{
            target = $target; toolchain = '1.93.1'; features = 'default'
            command = 'cargo +1.93.1 build --locked --release --target i686-pc-windows-msvc'
            rustc_verbose = $rustVersion; cargo = $cargoVersion; git = $gitVersion
            cargo_config_sha256 = Get-Sha256 (Join-Path $source '.cargo\config.toml')
            operating_system = [Environment]::OSVersion.VersionString
            runner_image = $env:ImageVersion
        }
        files = $hashes
    }
    $json = ($manifest | ConvertTo-Json -Depth 8) + "`n"
    [IO.File]::WriteAllText((Join-Path $OutputDirectory 'manifest.json'), $json, (New-Object Text.UTF8Encoding($false)))
    Write-Output "Built candidate DLL: $OutputDirectory"
    Write-Output "DLL SHA256: $($hashes['rust_g.dll'].sha256)"
} finally {
    $env:RUSTUP_AUTO_INSTALL = $previousAutoInstall
}
