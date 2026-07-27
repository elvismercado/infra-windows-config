$script:LogFile = Join-Path (Join-Path $PSScriptRoot "..") "setup.log"

function Start-Log {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $script:LogFile -Value "`n===== Setup started at $timestamp ====="
}

function Write-Info {
    param([string]$Message)
    Write-Host "[setup] $Message" -ForegroundColor Green
    Add-Content -Path $script:LogFile -Value "[INFO]  $Message"
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[setup] $Message" -ForegroundColor Yellow
    Add-Content -Path $script:LogFile -Value "[WARN]  $Message"
}

function Write-Err {
    param([string]$Message)
    Write-Host "[setup] $Message" -ForegroundColor Red
    Add-Content -Path $script:LogFile -Value "[ERROR] $Message"
}

function Confirm-Step {
    param([string]$Prompt)
    $answer = Read-Host "$Prompt [y/N]"
    return ($answer -eq 'y' -or $answer -eq 'Y')
}

function Get-Settings {
    $settingsPath = Join-Path (Join-Path $PSScriptRoot "..") "settings.json"
    if (-not (Test-Path $settingsPath)) {
        Write-Err "settings.json not found at $settingsPath"
        exit 1
    }
    return Get-Content $settingsPath -Raw | ConvertFrom-Json
}

function Start-SetupTimer {
    return [Diagnostics.Stopwatch]::StartNew()
}

function Write-Elapsed {
    param([Diagnostics.Stopwatch]$Timer)
    $elapsed = $Timer.Elapsed
    Write-Info ("Total time: {0}m {1}s" -f [int]$elapsed.TotalMinutes, $elapsed.Seconds)
}
