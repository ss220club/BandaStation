# Run in a fresh PowerShell process: mocks stay local to this focused check.
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'native-harness-helpers.ps1')
function Assert-Check($Condition, [string]$Message) { if (-not $Condition) { throw $Message } }
function New-Fault([DateTime]$Time, [string]$FaultPid, [string]$Message = 'dd.exe') {
    $event = [pscustomobject]@{ TimeCreated = $Time; Message = $Message; Properties = @(); Xml = "<Event><EventData><Data Name='ProcessId'>$FaultPid</Data></EventData></Event>" }
    $event | Add-Member -MemberType ScriptMethod -Name ToXml -Value { $this.Xml }
    return $event
}
function Get-WinEvent { param($FilterHashtable, $ErrorAction) return $script:testEvents }
$start = [DateTime]'2026-10-25T12:00:00'
$windows = @{}
Register-ProcessWindow $windows 11 $start $start.AddSeconds(3)
Register-ProcessWindow $windows 11 $start.AddSeconds(60) $start.AddSeconds(65)
$script:testEvents = @(
    (New-Fault $start.AddSeconds(2) '0xb'),
    (New-Fault $start.AddSeconds(12) '11'),
    (New-Fault $start.AddSeconds(100) '11'),
    (New-Fault $start.AddSeconds(2) '42'),
    (New-Fault $start.AddSeconds(2) 'invalid')
)
$evidence = Get-FaultEvidence $start.AddMinutes(-1) $windows
Assert-Check ($evidence.events.Count -eq 2) 'Expected both recorded lifetimes to match.'
Assert-Check ($evidence.outside_lifetime_events.Count -eq 1) 'PID reuse evidence must be retained separately.'
Assert-Check ($evidence.unparsed_daemon_events.Count -eq 1) 'Unknown daemon PID must not be silently ignored.'
Assert-Check (-not $evidence.query_error) 'Unexpected query error.'
function Get-WinEvent { param($FilterHashtable, $ErrorAction) throw 'deliberate event query failure' }
Assert-Check ((Get-FaultEvidence $start $windows).query_error -like '*deliberate event query failure*') 'Query failure was hidden.'
function Get-WinEvent { param($FilterHashtable, $ErrorAction) Write-Error 'none' -ErrorId NoMatchingEventsFound -ErrorAction Stop }
$empty = Get-FaultEvidence $start $windows
Assert-Check (-not $empty.query_error -and $empty.events.Count -eq 0) 'No matching events is a valid empty result.'

$flags = @('RUSTFLAGS', 'CARGO_ENCODED_RUSTFLAGS', 'CARGO_BUILD_RUSTFLAGS', 'CARGO_TARGET_I686_PC_WINDOWS_MSVC_RUSTFLAGS', 'CARGO_TARGET_DIR')
$saved = @{}
try {
    foreach ($name in $flags) { $saved[$name] = [Environment]::GetEnvironmentVariable($name); [Environment]::SetEnvironmentVariable($name, $null) }
    foreach ($name in $flags) {
        [Environment]::SetEnvironmentVariable($name, 'deliberate-recipe-override')
        $rejected = $false
        try { & (Join-Path $PSScriptRoot '..\rustg\build-windows.ps1') } catch { $rejected = $_.Exception.Message -like "Unset $name *" }
        Assert-Check $rejected "Build must reject $name before tools/download/build."
        [Environment]::SetEnvironmentVariable($name, $null)
    }
} finally { foreach ($name in $flags) { [Environment]::SetEnvironmentVariable($name, $saved[$name]) } }
Write-Output 'Native evidence windows/query errors and five Cargo environment guards: PASS'

