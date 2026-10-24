# Mutable task data must not live under Codex's protected .agents directory.
$taskWorkspace = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$taskRoot = Join-Path $taskWorkspace 'task_state'
$taskLegacyRoot = Join-Path $taskWorkspace '.AGENTS/local'
$taskTemplates = Join-Path $taskWorkspace '.AGENTS/templates'
$taskUtf8 = New-Object Text.UTF8Encoding($false, $true)

function Assert-TaskDirectory([string]$Path, [switch]$AllowMissing) {
    if ($AllowMissing -and -not (Test-Path -LiteralPath $Path)) { return }
    $item = Get-Item -LiteralPath $Path -Force
    if (-not $item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw ('Expected an ordinary state directory: '+$Path)
    }
}

Assert-TaskDirectory $taskWorkspace
Assert-TaskDirectory (Join-Path $taskWorkspace '.AGENTS') -AllowMissing
Assert-TaskDirectory $taskLegacyRoot -AllowMissing
Assert-TaskDirectory $taskRoot -AllowMissing
