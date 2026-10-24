$ErrorActionPreference = 'Stop'
$WorkspaceRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$agentUtf8 = New-Object Text.UTF8Encoding($false, $true)

function Assert-AgentPath([string]$Path, [switch]$AllowMissing) {
    $full = [IO.Path]::GetFullPath($Path)
    $cursor = $full
    while ($cursor) {
        if ((Test-Path -LiteralPath $cursor) -and ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw ('Redirected agent path: '+$cursor)
        }
        $parent = Split-Path -Parent $cursor
        if ($parent -eq $cursor) { break }
        $cursor = $parent
    }
    if (-not $AllowMissing -and -not (Test-Path -LiteralPath $full)) { throw ('Missing agent path: '+$full) }
}
function Local-Path([string]$Relative) {
    $full = [IO.Path]::GetFullPath((Join-Path $WorkspaceRoot $Relative))
    if (-not $full.StartsWith($WorkspaceRoot+[IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw ('Path escapes checkout: '+$Relative)
    }
    Assert-AgentPath $full -AllowMissing
    return $full
}
function Write-Utf8([string]$Path, [string]$Text) {
    Assert-AgentPath $Path -AllowMissing
    [IO.Directory]::CreateDirectory((Split-Path -Parent $Path)) | Out-Null
    [IO.File]::WriteAllText($Path, $Text, $agentUtf8)
}
function File-Hash([string]$Path) {
    $sha = [Security.Cryptography.SHA256]::Create()
    $stream = [IO.File]::OpenRead($Path)
    try { return [BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','').ToLowerInvariant() }
    finally { $stream.Dispose(); $sha.Dispose() }
}
function Find-Node { return (Get-Command node.exe -ErrorAction Stop).Source }
function New-AgentTemporaryDirectory {
    $root = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/')
    Assert-AgentPath $root
    $path = Join-Path $root ('bandastation-agent-test-'+[Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $path | Out-Null
    return $path
}
function Remove-AgentTemporaryDirectory([string]$Path) {
    $full = [IO.Path]::GetFullPath($Path)
    $root = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/')
    if ((Split-Path -Parent $full) -ne $root -or -not (Split-Path -Leaf $full).StartsWith('bandastation-agent-test-')) {
        throw ('Unexpected temporary cleanup path: '+$full)
    }
    Assert-AgentPath $full
    Get-ChildItem -LiteralPath $full -Recurse -Force | ForEach-Object { Assert-AgentPath $_.FullName }
    Remove-Item -LiteralPath $full -Recurse -Force
}
