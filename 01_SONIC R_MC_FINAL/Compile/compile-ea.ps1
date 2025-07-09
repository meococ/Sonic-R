# APEX Pullback EA - PowerShell Compilation Script
# Handles Unicode log files properly

param(
    [switch]$Silent = $true, # Force silent mode
    [switch]$Quick = $false
)

# Define paths
$BatchDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CompilerPath = "C:\Program Files\MetaTrader 5\metaeditor64.exe"
$SourceFile = Join-Path $BatchDir "..\A EA_SonicR_MC.mq5"
$LogFile = Join-Path $BatchDir "_compilation_log.txt"

# Clean up old log file
if (Test-Path $LogFile) {
    Write-Host "Deleting old log file: $LogFile"
    Remove-Item $LogFile -Force
}

# Check if compiler exists
if (-not (Test-Path $CompilerPath)) {
    Write-Host "[ERROR] MetaEditor64 not found at $CompilerPath"
    exit 1
}

# Run compilation
Write-Host "Starting compilation..."
$process = Start-Process -FilePath $CompilerPath -ArgumentList "/compile:`"$SourceFile`"", "/log:`"$LogFile`"" -Wait -NoNewWindow -PassThru
Write-Host "Compilation process finished with Exit Code: $($process.ExitCode)"

# Wait for log file to be written
Start-Sleep -Seconds 2

# Check results
if (Test-Path $LogFile) {
    Write-Host "Log file found at: $LogFile"
    # Read log file content (handles Unicode properly)
    $logContent = Get-Content $LogFile -Encoding UTF8
    Write-Host "Log file read. Total lines: $($logContent.Length)"
    
    # Just print all error lines to stdout
    $errorLines = $logContent | Select-String -Pattern "error" -CaseSensitive:$false
    Write-Host "Found $($errorLines.Count) lines with 'error'."
    $errorLines | ForEach-Object { Write-Host $_.Line }

    # Return the actual exit code from the compiler
    exit $process.ExitCode
} else {
    Write-Host "[ERROR] No compilation log file was generated"
    exit 1
}