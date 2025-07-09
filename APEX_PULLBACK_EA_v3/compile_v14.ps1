# APEX Pullback EA - PowerShell Compilation Script for v14.0
# Handles Unicode log files properly

param(
    [string]$EaName = "APEX PULLBACK EA v14.0",
    [switch]$Silent = $false,
    [switch]$Quick = $false
)

# Define paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CompilerPath = "C:\Program Files\MetaTrader 5\metaeditor64.exe"
$SourceFile = Join-Path $ScriptDir "$($EaName).mq5"
$LogFile = Join-Path $ScriptDir "_compilation_log_v14.txt"

# Clean up old log file
if (Test-Path $LogFile) {
    Remove-Item $LogFile -Force
}

# Check if compiler exists
if (-not (Test-Path $CompilerPath)) {
    Write-Host "[ERROR] MetaEditor64 not found at $CompilerPath" -ForegroundColor Red
    exit 1
}

# Check if source file exists
if (-not (Test-Path $SourceFile)) {
    Write-Host "[ERROR] Source file not found at $SourceFile" -ForegroundColor Red
    exit 1
}

if (-not $Silent -and -not $Quick) {
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "APEX PULLBACK EA v14.0 - POWERSHELL COMPILATION" -ForegroundColor Cyan
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "Source File: $SourceFile" -ForegroundColor Gray
    Write-Host ""
}

# Run compilation
if (-not $Silent) {
    Write-Host "Compiling..." -ForegroundColor Yellow
}

Start-Process -FilePath $CompilerPath -ArgumentList "/compile:`"$SourceFile`"", "/log:`"$LogFile`"" -Wait -NoNewWindow

# Wait for log file to be written
Start-Sleep -Seconds 2

# Check results
if (Test-Path $LogFile) {
    # Read log file content (handles Unicode properly)
    $logContent = Get-Content $LogFile -Encoding UTF8
    
    # Count errors and warnings
    $errors = ($logContent | Select-String -Pattern "error" -CaseSensitive:$false).Count
    $warnings = ($logContent | Select-String -Pattern "warning" -CaseSensitive:$false).Count
    
    if ($Quick) {
        Write-Host "[QUICK CHECK] Errors: $errors - Warnings: $warnings" -ForegroundColor $(if ($errors -gt 0) { "Red" } else { "Green" })
        if ($errors -gt 0) {
            Write-Host "First 3 errors:" -ForegroundColor Yellow
            $logContent | Select-String -Pattern "error" -CaseSensitive:$false | Select-Object -First 3 | ForEach-Object { Write-Host $_.Line -ForegroundColor Red }
        }
    }
    elseif ($Silent) {
        if ($errors -gt 0) {
            Write-Host "[COMPILE FAILED] - $errors errors, $warnings warnings" -ForegroundColor Red
            # Show first few errors
            $logContent | Select-String -Pattern "error" -CaseSensitive:$false | Select-Object -First 5 | ForEach-Object { Write-Host $_.Line -ForegroundColor Red }
        } else {
            Write-Host "[COMPILE SUCCESS] - No errors ($warnings warnings)" -ForegroundColor Green
        }
    }
    else {
        Write-Host ""
        Write-Host "Compilation Results:" -ForegroundColor Cyan
        Write-Host "------------------------------------" -ForegroundColor Gray
        Write-Host "Errors: $errors" -ForegroundColor $(if ($errors -gt 0) { "Red" } else { "Green" })
        Write-Host "Warnings: $warnings" -ForegroundColor $(if ($warnings -gt 0) { "Yellow" } else { "Green" })
        Write-Host "------------------------------------" -ForegroundColor Gray
        
        if ($errors -gt 0) {
            Write-Host ""
            Write-Host "*** COMPILATION FAILED ***" -ForegroundColor Red
            Write-Host "Compilation Log: $LogFile" -ForegroundColor Gray
            Write-Host "First 10 errors:" -ForegroundColor Yellow
            $logContent | Select-String -Pattern "error" -CaseSensitive:$false | Select-Object -First 10 | ForEach-Object { Write-Host $_.Line -ForegroundColor Red }
        } else {
            Write-Host ""
            Write-Host "*** COMPILATION SUCCESSFUL ***" -ForegroundColor Green
        }
    }
    
    # Return appropriate exit code
    if ($errors -gt 0) {
        exit 1
    } else {
        exit 0
    }
} else {
    Write-Host "[ERROR] No compilation log file was generated" -ForegroundColor Red
    exit 1
}