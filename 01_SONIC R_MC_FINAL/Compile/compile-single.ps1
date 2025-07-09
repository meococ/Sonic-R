# APEX Pullback EA - Single File Compilation Script
# Handles Unicode log files properly

param(
    [Parameter(Mandatory=$true)]
    [string]$FileName,
    [switch]$Silent = $false,
    [switch]$Quick = $false
)

# Define paths
$BatchDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CompilerPath = "C:\Program Files\MetaTrader 5\metaeditor64.exe"
$SourceFile = Join-Path $BatchDir "..\$FileName"
$LogFile = Join-Path $BatchDir "_single_compilation_log.txt"

# Validate source file exists
if (-not (Test-Path $SourceFile)) {
    Write-Host "[ERROR] Source file not found: $SourceFile" -ForegroundColor Red
    exit 1
}

# Clean up old log file
if (Test-Path $LogFile) {
    Remove-Item $LogFile -Force
}

# Check if compiler exists
if (-not (Test-Path $CompilerPath)) {
    Write-Host "[ERROR] MetaEditor64 not found at $CompilerPath" -ForegroundColor Red
    exit 1
}

if (-not $Silent -and -not $Quick) {
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "APEX PULLBACK EA - SINGLE FILE COMPILATION" -ForegroundColor Cyan
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "Target File: $SourceFile" -ForegroundColor Gray
    Write-Host ""
}

# Run compilation
if (-not $Silent) {
    Write-Host "Compiling $FileName..." -ForegroundColor Yellow
}

Start-Process -FilePath $CompilerPath -ArgumentList "/compile:`"$SourceFile`"", "/log:`"$LogFile`"" -Wait -NoNewWindow

# Wait for log file to be written
Start-Sleep -Seconds 2

# Check results
if (Test-Path $LogFile) {
    # Read log file content (handles Unicode properly)
    $logContent = Get-Content $LogFile -Encoding UTF8
    
    # Extract final result line to get accurate count
    $resultLine = $logContent | Where-Object { $_ -match "^Result:" } | Select-Object -Last 1
    
    if ($resultLine -match "Result:\s*(\d+)\s*errors?,\s*(\d+)\s*warnings?") {
        $errors = [int]$matches[1]
        $warnings = [int]$matches[2]
    } else {
        # Fallback to pattern matching for actual error/warning messages (not filenames)
        $errors = ($logContent | Select-String -Pattern ":\s*error\s*:" -CaseSensitive:$false).Count
        $warnings = ($logContent | Select-String -Pattern ":\s*warning\s*:" -CaseSensitive:$false).Count
    }
    
    if ($Quick) {
        Write-Host "[$FileName] Errors: $errors - Warnings: $warnings" -ForegroundColor $(if ($errors -gt 0) { "Red" } else { "Green" })
        if ($errors -gt 0) {
            Write-Host "First 3 errors:" -ForegroundColor Yellow
            $logContent | Select-String -Pattern ":\s*error\s*:" -CaseSensitive:$false | Select-Object -First 3 | ForEach-Object { Write-Host $_.Line -ForegroundColor Red }
        }
    }
    elseif ($Silent) {
        if ($errors -gt 0) {
            Write-Host "[$FileName] FAILED - $errors errors, $warnings warnings" -ForegroundColor Red
        } else {
            Write-Host "[$FileName] SUCCESS - 0 errors ($warnings warnings)" -ForegroundColor Green
        }
    }
    else {
        Write-Host ""
        Write-Host "Errors: $errors" -ForegroundColor $(if ($errors -gt 0) { "Red" } else { "Green" })
        Write-Host "Warnings: $warnings" -ForegroundColor $(if ($warnings -gt 0) { "Yellow" } else { "Green" })
        Write-Host "------------------------------------" -ForegroundColor Gray

        if ($errors -gt 0) {
            Write-Host ""
            Write-Host "*** COMPILATION FAILED ***" -ForegroundColor Red
            Write-Host "Errors in $FileName`:" -ForegroundColor Yellow
            $logContent | Select-String -Pattern ":\s*error\s*:" -CaseSensitive:$false | ForEach-Object { Write-Host $_.Line -ForegroundColor Red }
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