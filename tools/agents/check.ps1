# Offline verification in dedicated TEMP fixtures; no product build or package download.
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')
& py -3 -B (Join-Path $PSScriptRoot 'check-content.py')
if ($LASTEXITCODE -ne 0) { throw 'Agent content/inspector checks failed.' }
foreach ($script in Get-ChildItem -LiteralPath $PSScriptRoot -File -Filter '*.ps1') {
    $tokens = $null; $errors = $null
    [Management.Automation.Language.Parser]::ParseFile($script.FullName, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count) { throw ('PowerShell syntax: '+$script.Name+' '+$errors[0].Message) }
}
$node = Find-Node
foreach ($script in Get-ChildItem -LiteralPath $PSScriptRoot -Recurse -File | Where-Object { $_.Extension -in @('.cjs','.mjs') }) {
    & $node --check $script.FullName
    if ($LASTEXITCODE -ne 0) { throw ('JavaScript syntax: '+$script.Name) }
}
Write-Output 'PASS: agent PowerShell and JavaScript syntax'

$stage = New-AgentTemporaryDirectory
try {
    $fixtureRoot = Join-Path $stage 'workspace'
    $fixtureTools = Join-Path $fixtureRoot 'tools/agents'
    $fixtureState = Join-Path $fixtureRoot 'task_state'
    $fixtureLegacy = Join-Path $fixtureRoot '.AGENTS/local'
    [IO.Directory]::CreateDirectory($fixtureTools) | Out-Null
    [IO.Directory]::CreateDirectory((Join-Path $fixtureRoot '.AGENTS')) | Out-Null
    Copy-Item -LiteralPath (Local-Path '.AGENTS/templates') -Destination (Join-Path $fixtureRoot '.AGENTS/templates') -Recurse
    foreach ($script in @('new-task.ps1','task.ps1','task-paths.ps1')) {
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot $script) -Destination (Join-Path $fixtureTools $script)
    }
    $create = Join-Path $fixtureTools 'new-task.ps1'
    $read = Join-Path $fixtureTools 'task.ps1'
    $empty = (& $read -Action list) -join "`n"
    if (-not $empty.Contains('No local tasks.') -or (Test-Path -LiteralPath $fixtureState)) { throw 'Empty listing wrote state or failed.' }
    $title = 'Literal {{TASK_ID}} $name'
    & $create -TaskId test-agent-state -Title $title | Out-Null
    $created = Join-Path $fixtureState 'test-agent-state'
    if (@(Get-ChildItem -LiteralPath $created -File).Count -ne 4) { throw 'Task template set changed.' }
    foreach ($file in Get-ChildItem -LiteralPath $created -File) {
        if (-not [IO.File]::ReadAllText($file.FullName, $agentUtf8).Contains($title)) { throw 'Title was expanded or lost.' }
    }
    $before = File-Hash (Join-Path $created 'TODO.md')
    $rejected = $false
    try { & $create -TaskId test-agent-state -Title overwrite | Out-Null } catch { $rejected = $true }
    if (-not $rejected -or (File-Hash (Join-Path $created 'TODO.md')) -ne $before) { throw 'Existing task was overwritten.' }
    $rejected = $false
    try { & $create -TaskId '../escape' -Title invalid | Out-Null } catch { $rejected = $true }
    if (-not $rejected) { throw 'Task path traversal was accepted.' }
    $listing = (& $read -Action list) -join "`n"
    if (-not $listing.Contains('test-agent-state | active |')) { throw 'Listing lost ID/status.' }
    $resume = (& $read -Action resume -TaskId test-agent-state) -join "`n"
    if (-not $resume.Contains($title) -or (File-Hash (Join-Path $created 'TODO.md')) -ne $before) { throw 'Resume changed or lost state.' }
    foreach ($parameters in @(@{Action='resume'}, @{Action='resume';TaskId='missing-task'})) {
        $rejected = $false
        try { & $read @parameters | Out-Null } catch { $rejected = $true }
        if (-not $rejected) { throw 'Resume silently selected/created a task.' }
    }
    Write-Output 'PASS: task creation, literal title, no overwrite, path bounds, explicit read-only resume'

    [IO.Directory]::CreateDirectory($fixtureLegacy) | Out-Null
    $legacy = Join-Path $fixtureLegacy 'legacy-task'
    Copy-Item -LiteralPath $created -Destination $legacy -Recurse
    Write-Utf8 (Join-Path $legacy 'helpers/continue.ps1') '# required helper'
    $legacyHashes = @{}
    foreach ($file in Get-ChildItem -LiteralPath $legacy -File -Recurse) {
        $legacyHashes[$file.FullName.Substring($legacy.Length+1)] = File-Hash $file.FullName
    }
    $legacyResume = (& $read -Action resume -TaskId legacy-task) -join "`n"
    if (-not $legacyResume.Contains($legacy) -or -not $legacyResume.Contains('-Action migrate')) { throw 'Legacy resume lost migration instruction.' }
    $rejected = $false
    try { & $create -TaskId legacy-task -Title duplicate | Out-Null } catch { $rejected = $true }
    if (-not $rejected) { throw 'New task shadowed legacy state.' }
    & $read -Action migrate -TaskId legacy-task | Out-Null
    $migrated = Join-Path $fixtureState 'legacy-task'
    foreach ($relative in $legacyHashes.Keys) {
        if ((File-Hash (Join-Path $legacy $relative)) -ne $legacyHashes[$relative] -or
            (File-Hash (Join-Path $migrated $relative)) -ne $legacyHashes[$relative]) { throw ('Migration changed/lost '+$relative) }
    }
    $rejected = $false
    try { & $read -Action migrate -TaskId legacy-task | Out-Null } catch { $rejected = $true }
    if (-not $rejected) { throw 'Repeated migration overwrote state.' }
    Write-Utf8 (Join-Path $migrated 'TODO.md') "# Current state sentinel`n- Status: done`n"
    $listing = @(& $read -Action list | Where-Object { $_ -like 'legacy-task |*' })
    if ($listing.Count -ne 1 -or -not $listing[0].Contains('| done |')) { throw 'Listing duplicated task or used stale legacy state.' }
    $resume = (& $read -Action resume -TaskId legacy-task) -join "`n"
    if (-not $resume.Contains('Current state sentinel') -or -not $resume.Contains($migrated)) { throw 'Resume selected stale state.' }
    Write-Output 'PASS: byte-preserving legacy migration with helpers; no overwrite; current state precedence'

    $redirect = Join-Path $fixtureLegacy 'redirected-task'
    try {
        New-Item -ItemType Junction -Path $redirect -Target $legacy | Out-Null
        foreach ($action in @('resume','migrate')) {
            $rejected = $false
            try { & $read -Action $action -TaskId redirected-task | Out-Null } catch { $rejected = $true }
            if (-not $rejected) { throw ('Redirected task accepted by '+$action) }
        }
        if (Test-Path -LiteralPath (Join-Path $fixtureState 'redirected-task')) { throw 'Rejected migration left state.' }
    } finally {
        if (Test-Path -LiteralPath $redirect) {
            if (-not $redirect.StartsWith($fixtureRoot+'\', [StringComparison]::OrdinalIgnoreCase) -or
                (Get-Item -LiteralPath $redirect -Force).LinkType -ne 'Junction') { throw 'Unexpected junction cleanup target' }
            [IO.Directory]::Delete($redirect)
        }
    }
    $incomplete = Join-Path $fixtureLegacy 'copy-failure-task'
    Copy-Item -LiteralPath $legacy -Destination $incomplete -Recurse
    $locked = [IO.File]::Open((Join-Path $incomplete 'TODO.md'), 'Open', 'ReadWrite', 'None')
    try {
        $rejected = $false
        try { & $read -Action migrate -TaskId copy-failure-task | Out-Null } catch { $rejected = $true }
        if (-not $rejected -or (Test-Path -LiteralPath (Join-Path $fixtureState 'copy-failure-task'))) { throw 'Failed migration left partial state.' }
    } finally { $locked.Dispose() }
    & $read -Action migrate -TaskId copy-failure-task | Out-Null
    if ((File-Hash (Join-Path $fixtureState 'copy-failure-task/TODO.md')) -ne (File-Hash (Join-Path $incomplete 'TODO.md'))) { throw 'Migration retry lost content.' }
    Write-Output 'PASS: redirected tasks rejected; interrupted copy cleans its partial destination; retry succeeds'
} finally { Remove-AgentTemporaryDirectory $stage }
Write-Output 'PASS: temporary task fixture cleanup'

& py -3 -B (Join-Path $PSScriptRoot 'test-toolkit.py')
if ($LASTEXITCODE -ne 0) { throw 'Portable installer checks failed.' }
& (Join-Path $PSScriptRoot 'local-only.ps1') -Action check
