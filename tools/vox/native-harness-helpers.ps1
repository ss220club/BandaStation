# Shared evidence helpers; sourcing this file never launches a process.
function Write-ArtifactJson([string]$Path, $Value) {
    $artifactUtf8 = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($Path, (ConvertTo-Json -InputObject $Value -Depth 12), $artifactUtf8)
}

function Read-FaultPid($Value) {
    $text = ([string]$Value).Trim()
    try {
        if ($text -match '^0x([0-9a-f]+)$') { return [Convert]::ToInt32($Matches[1], 16) }
        if ($text -match '^[0-9]+$') { return [int]$text }
        if ($text -match '^[0-9a-f]+$') { return [Convert]::ToInt32($text, 16) }
    } catch { return $null }
    return $null
}

function Register-ProcessWindow([hashtable]$Windows, [int]$ProcessId, [DateTime]$Start, [DateTime]$End) {
    $window = @{ start = $Start; end = $End }
    if ($Windows.ContainsKey($ProcessId)) { $Windows[$ProcessId] += @($window) } else { $Windows[$ProcessId] = @($window) }
}

function Get-FaultEvidence([DateTime]$Since, [hashtable]$ProcessWindows) {
    $matched = @(); $unparsed = @(); $queryError = $null
    try {
        $rawEvents = @(Get-WinEvent -FilterHashtable @{ LogName = 'Application'; Id = 1000; StartTime = $Since } -ErrorAction Stop)
    } catch {
        $rawEvents = @()
        if ($_.FullyQualifiedErrorId -notlike 'NoMatchingEventsFound*') { $queryError = $_.Exception.Message }
    }
    foreach ($event in $rawEvents) {
        $xmlText = $event.ToXml(); [xml]$xml = $xmlText
        $data = @{}
        foreach ($field in $xml.Event.EventData.Data) { $data[[string]$field.Name] = [string]$field.'#text' }
        $faultPid = Read-FaultPid $data['ProcessId']
        if ($null -eq $faultPid) { $faultPid = Read-FaultPid $data['FaultingProcessId'] }
        if ($null -eq $faultPid -and $event.Properties.Count -gt 8) { $faultPid = Read-FaultPid $event.Properties[8].Value }
        if ($null -eq $faultPid) {
            if ($event.Message -match '\bdd\.exe\b|\bdm\.exe\b') { $unparsed += @{ time = $event.TimeCreated; message = $event.Message; xml = $xmlText } }
            continue
        }
        if (-not $ProcessWindows.ContainsKey($faultPid)) { continue }
        $windows = @($ProcessWindows[$faultPid])
        $withinLifetime = @($windows | Where-Object { $event.TimeCreated -ge $_.start.AddSeconds(-2) -and $event.TimeCreated -le $_.end.AddSeconds(15) }).Count -gt 0
        # Retain every tested PID match, even delayed WER events or ambiguous PID reuse.
        $matched += @{ pid = $faultPid; time = $event.TimeCreated; within_recorded_lifetime = $withinLifetime; process_windows = $windows; data = $data; message = $event.Message; xml = $xmlText }
    }
    return @{ events = $matched; unparsed_daemon_events = $unparsed; query_error = $queryError }
}
