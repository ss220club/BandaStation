param([ValidateSet('install','check')][string]$Action = 'check')
. (Join-Path $PSScriptRoot 'common.ps1')
$paths = @(':(icase).codex', ':(icase)task_state', ':(icase).AGENTS/local')
$tracked = @(& git -C $WorkspaceRoot ls-files -- $paths)
if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect Git index.' }
if ($tracked.Count) { throw ('Local runtime files are tracked/staged; preserve the index and remove them explicitly: '+($tracked -join ', ')) }
$configuredHooks = [string](& git -C $WorkspaceRoot config --get core.hooksPath)
if ($configuredHooks) { throw ('Custom core.hooksPath is preserved; integrate the runtime guard explicitly: '+$configuredHooks) }
$hookRelative = [string](& git -C $WorkspaceRoot rev-parse --git-path hooks/pre-commit)
if ($LASTEXITCODE -ne 0) { throw 'Not a Git checkout.' }
$hookPath = if ([IO.Path]::IsPathRooted($hookRelative)) { $hookRelative } else { Join-Path $WorkspaceRoot $hookRelative }
$hookSource = Local-Path '.AGENTS/templates/pre-commit'
Assert-AgentPath $hookPath -AllowMissing
$marker = '# Managed BandaStation agent runtime guard v2.'
if ((Test-Path -LiteralPath $hookPath) -and -not [IO.File]::ReadAllText($hookPath).Contains($marker)) {
    throw 'Existing custom pre-commit hook is preserved; integrate the guard explicitly.'
}
$excludeRelative = [string](& git -C $WorkspaceRoot rev-parse --git-path info/exclude)
$excludePath = if ([IO.Path]::IsPathRooted($excludeRelative)) { $excludeRelative } else { Join-Path $WorkspaceRoot $excludeRelative }
Assert-AgentPath $excludePath -AllowMissing
$begin = '# BEGIN BandaStation agent runtime'
$end = '# END BandaStation agent runtime'
$rules = @('/.codex/','/task_state/','/.AGENTS/local/','/.agents/local/')
if ($Action -eq 'install') {
    $existing = if (Test-Path -LiteralPath $excludePath) { [IO.File]::ReadAllText($excludePath, $agentUtf8) } else { '' }
    if ($existing.Contains($begin) -ne $existing.Contains($end)) { throw 'Incomplete existing runtime exclude block.' }
    if (-not $existing.Contains($begin)) {
        Write-Utf8 $excludePath ($existing.TrimEnd()+"`n`n"+$begin+"`n"+($rules -join "`n")+"`n"+$end+"`n")
    }
    Write-Utf8 $hookPath ([IO.File]::ReadAllText($hookSource, $agentUtf8).Replace("`r`n","`n"))
}
foreach ($probe in @('.codex/config.toml','task_state/probe/TODO.md','.AGENTS/local/probe.md','.agents/local/probe.md')) {
    & git -C $WorkspaceRoot check-ignore --quiet --no-index -- $probe
    if ($LASTEXITCODE -ne 0) { throw ('Missing local runtime exclusion: '+$probe) }
}
foreach ($probe in @('AGENTS.md','.AGENTS/templates/PLAN.md','tools/agents/setup-tools.ps1')) {
    & git -C $WorkspaceRoot check-ignore --quiet --no-index -- $probe
    if ($LASTEXITCODE -eq 0) { throw ('Shared toolkit sources must remain visible to Git: '+$probe) }
    if ($LASTEXITCODE -ne 1) { throw ('Cannot inspect source visibility: '+$probe) }
}
if (-not (Test-Path -LiteralPath $hookPath) -or (File-Hash $hookPath) -ne (File-Hash $hookSource)) { throw 'Runtime pre-commit guard is missing or differs from its template.' }
Write-Output 'PASS: shared toolkit sources are versionable; runtime paths ignored and unstaged; pre-commit guard installed.'
