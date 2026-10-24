param(
    [ValidateSet('list','resume','migrate')][string]$Action = 'list',
    [ValidatePattern('^[a-z0-9][a-z0-9-]{2,79}$')][string]$TaskId
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'task-paths.ps1')
function Read-TaskTodo([string]$Directory) {
    Assert-TaskDirectory $Directory
    $file = Join-Path $Directory 'TODO.md'
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { return $null }
    if ((Get-Item -LiteralPath $file -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw ('Redirected task state: '+$file)
    }
    return [IO.File]::ReadAllText($file, $taskUtf8)
}
if ($Action -eq 'list') {
    if ($TaskId) { throw 'Use -TaskId only with -Action resume or migrate.' }
    $byId = @{}
    # Current state wins after migration; never show two versions of one task.
    foreach ($root in @($taskLegacyRoot, $taskRoot)) {
        if (Test-Path -LiteralPath $root) {
            foreach ($entry in Get-ChildItem -LiteralPath $root -Directory) { $byId[$entry.Name] = $entry }
        }
    }
    $directories = @($byId.Values | Sort-Object Name)
    if (-not $directories.Count) { Write-Output 'No local tasks. Use tools/agents/new-task.ps1.' }
    foreach ($directory in $directories) {
        $todo = Read-TaskTodo $directory.FullName
        # Status values are stable across the original and compact TODO templates.
        $status = if ($todo -match '(?m)^- [^:\r\n]+: (active|blocked|done|superseded)\s*$') { $Matches[1] } else { 'unknown' }
        $title = if ($todo -match '(?m)^# ([^\r\n]+)') { $Matches[1] } else { 'TODO missing' }
        $source = if ($directory.Parent.FullName -eq $taskRoot) { 'task_state' } else { 'legacy; migrate before editing' }
        Write-Output ($directory.Name+' | '+$status+' | '+$title+' | '+$source)
    }
    return
}
if (-not $TaskId) { throw ('-Action '+$Action+' requires an explicit -TaskId.') }
$directory = Join-Path $taskRoot $TaskId
if ($Action -eq 'migrate') {
    if (Test-Path -LiteralPath $directory) { throw ('Task state already exists; migration never overwrites: '+$directory) }
    $source = Join-Path $taskLegacyRoot $TaskId
    Assert-TaskDirectory $source
    # Validate the complete source before creating a destination. Never follow links.
    function Get-TaskSourceFiles([string]$Path) {
        foreach ($entry in Get-ChildItem -LiteralPath $Path -Force) {
            if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw ('Redirected task state: '+$entry.FullName) }
            if ($entry.PSIsContainer) { Get-TaskSourceFiles $entry.FullName } else { $entry }
        }
    }
    $files = @(Get-TaskSourceFiles $source)
    foreach ($name in @('PLAN.md','TODO.md','DECISIONS.md','EVIDENCE.md')) {
        if (-not (Test-Path -LiteralPath (Join-Path $source $name) -PathType Leaf)) { throw ('Missing legacy task document: '+$name) }
    }
    [IO.Directory]::CreateDirectory($taskRoot) | Out-Null
    Assert-TaskDirectory $taskRoot
    New-Item -ItemType Directory -Path $directory | Out-Null
    try {
        foreach ($file in $files) {
            $target = Join-Path $directory $file.FullName.Substring($source.Length+1)
            [IO.Directory]::CreateDirectory((Split-Path -Parent $target)) | Out-Null
            [IO.File]::Copy($file.FullName, $target, $false)
        }
    } catch {
        # Only this invocation created the destination. A partial copy must not
        # shadow the complete legacy task on the next list/resume.
        $full = [IO.Path]::GetFullPath($directory)
        if ((Split-Path -Parent $full) -ne $taskRoot) { throw 'Unexpected migration cleanup target' }
        Assert-TaskDirectory $taskRoot
        Assert-TaskDirectory $full
        @(Get-TaskSourceFiles $full) | Out-Null
        Remove-Item -LiteralPath $full -Recurse -Force
        throw
    }
    Write-Output ('Migrated task state: '+$directory+' (legacy source unchanged)')
    return
}
if (-not (Test-Path -LiteralPath $directory)) { $directory = Join-Path $taskLegacyRoot $TaskId }
if (-not (Test-Path -LiteralPath $directory -PathType Container)) { throw ('Task not found: '+$TaskId) }
$todo = Read-TaskTodo $directory
if ($null -eq $todo) { throw ('TODO.md not found for '+$TaskId+'; inspect its PLAN and recover from the current request.') }
Write-Output ('Task: '+$TaskId+' (read-only; no status or files changed)')
Write-Output ('State: '+$directory)
if ($directory -eq (Join-Path $taskLegacyRoot $TaskId)) {
    Write-Output ('Before editing: tools/agents/task.ps1 -Action migrate -TaskId '+$TaskId)
}
Write-Output $todo
