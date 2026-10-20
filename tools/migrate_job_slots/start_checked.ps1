[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string] $PlayerSaves,
    [Parameter(Mandatory = $true)] [string] $ServerCommand,
    [string[]] $ServerArguments = @()
)

$ErrorActionPreference = 'Stop'
$commandPath = (Resolve-Path -LiteralPath $ServerCommand).Path
& py -3 -B "$PSScriptRoot/migrate.py" $PlayerSaves --check-ready
$checkExit = $LASTEXITCODE
if ($checkExit -ne 0) {
    Write-Error "Player saves are not ready. The server was not started." -ErrorAction Continue
    exit $checkExit
}

# Preserve the caller's working directory and the configured server arguments.
& $commandPath @ServerArguments
exit $LASTEXITCODE
