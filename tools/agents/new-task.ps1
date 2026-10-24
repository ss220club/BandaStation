param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9][a-z0-9-]{2,79}$')]
    [string]$TaskId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Title
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($Title) -or $Title -match '[\r\n]') {
    throw 'Title must be non-empty and contain one line.'
}

. (Join-Path $PSScriptRoot 'task-paths.ps1')
$taskTarget = Join-Path $taskRoot $TaskId
Assert-TaskDirectory $taskTemplates
if (Test-Path -LiteralPath $taskTarget) {
    throw ('Task state already exists; read or resume it instead: ' + $taskTarget)
}
if (Test-Path -LiteralPath (Join-Path $taskLegacyRoot $TaskId)) {
    throw ('Legacy task already exists; use task.ps1 -Action migrate -TaskId '+$TaskId)
}

$taskCommit = 'unavailable'
if (Get-Command git -ErrorAction SilentlyContinue) {
    try {
        $taskHead = & git -C $taskWorkspace rev-parse --verify HEAD 2>$null
        if ($LASTEXITCODE -eq 0) { $taskCommit = [string]$taskHead }
    } catch {
        # Git metadata is optional in a copied toolkit fixture or before its first commit.
        $taskCommit = 'unavailable'
    }
}
$taskUpdatedAt = [DateTimeOffset]::UtcNow.ToOffset([TimeSpan]::FromHours(10)).ToString('o')
$taskDocuments = [ordered]@{}
$taskValues = @{
    '{{TASK_ID}}' = $TaskId
    '{{TITLE}}' = $Title
    '{{UPDATED_AT}}' = $taskUpdatedAt
    '{{BASE_COMMIT}}' = $taskCommit
}

# Validate and render all templates before creating anything. A single replace
# keeps token-like text in a user title literal instead of expanding it again.
foreach ($taskName in @('PLAN.md', 'TODO.md', 'DECISIONS.md', 'EVIDENCE.md')) {
    $taskText = [IO.File]::ReadAllText((Join-Path $taskTemplates $taskName), $taskUtf8)
    foreach ($taskToken in [regex]::Matches($taskText, '\{\{[^{}]+\}\}')) {
        if (-not $taskValues.ContainsKey($taskToken.Value)) {
            throw ('Unknown template token: ' + $taskToken.Value)
        }
    }
    $taskDocuments[$taskName] = [regex]::Replace($taskText, '\{\{[^{}]+\}\}', {
        param($taskMatch)
        return $taskValues[$taskMatch.Value]
    })
}

# No -Force: competing initialization of the same task must fail, not overwrite.
[IO.Directory]::CreateDirectory($taskRoot) | Out-Null
Assert-TaskDirectory $taskRoot
New-Item -ItemType Directory -Path $taskTarget | Out-Null
foreach ($taskName in $taskDocuments.Keys) {
    [IO.File]::WriteAllText((Join-Path $taskTarget $taskName), $taskDocuments[$taskName], $taskUtf8)
}
Write-Output ('Created task state: ' + $taskTarget)
Write-Output 'Fill PLAN and TODO before continuing; templates are not a completed plan.'
