# APEX Pullback EA - Compile All Files Script
# Handles Unicode log files properly

param(
    [switch]$Silent = $false,
    [switch]$Quick = $false,
    [switch]$StopOnError = $false
)

# Define paths
$BatchDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CompilerPath = "C:\Program Files\MetaTrader 5\metaeditor64.exe"
$ProjectDir = Split-Path -Parent $BatchDir

# Check if compiler exists
if (-not (Test-Path $CompilerPath)) {
    Write-Host "[ERROR] MetaEditor64 not found at $CompilerPath" -ForegroundColor Red
    exit 1
}

# Get all .mq5 and .mqh files
$AllFiles = Get-ChildItem $ProjectDir -Filter "*.mq*" | Where-Object { 
    $_.Extension -in @(".mq5", ".mqh") -and
    $_.Name -notmatch "^_" -and $_.Name -notmatch "Test" 
} | Sort-Object Name

if (-not $Silent) {
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "APEX PULLBACK EA - COMPILE ALL FILES" -ForegroundColor Cyan
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "Found $($AllFiles.Count) files to compile:" -ForegroundColor Gray
    $AllFiles | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
    Write-Host ""
}

# Compilation tracking
$TotalFiles = $AllFiles.Count
$SuccessCount = 0
$FailedFiles = @()
$TotalErrors = 0
$TotalWarnings = 0

# Compile each file
foreach ($File in $AllFiles) {
    $LogFile = Join-Path $BatchDir "_temp_compilation_log.txt"
    
    # Clean up old log file
    if (Test-Path $LogFile) {
        Remove-Item $LogFile -Force
    }
    
    if (-not $Silent) {
        Write-Host "Compiling $($File.Name)..." -ForegroundColor Yellow
    }
    
    # Run compilation
    Start-Process -FilePath $CompilerPath -ArgumentList "/compile:`"$($File.FullName)`"", "/log:`"$LogFile`"" -Wait -NoNewWindow
    
    # Wait for log file
    Start-Sleep -Seconds 1
    
    # Check results
    if (Test-Path $LogFile) {
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
        
        $TotalErrors += $errors
        $TotalWarnings += $warnings
        
        if ($errors -eq 0) {
            $SuccessCount++
            Write-Host "[$($File.Name)] SUCCESS - 0 errors ($warnings warnings)" -ForegroundColor Green
        } else {
            $FailedFiles += $File.Name
            Write-Host "[$($File.Name)] FAILED - $errors errors, $warnings warnings" -ForegroundColor Red
            
            if ($StopOnError) {
                Write-Host ""
                Write-Host "STOPPING ON FIRST ERROR AS REQUESTED" -ForegroundColor Red
                Write-Host "First error in $($File.Name):" -ForegroundColor Yellow
                $logContent | Select-String -Pattern ":\s*error\s*:" -CaseSensitive:$false | Select-Object -First 1 | ForEach-Object { Write-Host $_.Line -ForegroundColor Red }
                break
            }
        }
        
        # Clean up temp log file
        Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "[$($File.Name)] ERROR - No log file generated" -ForegroundColor Red
        $FailedFiles += $File.Name
    }
}

# Summary
if (-not $Silent) {
    Write-Host ""
    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "COMPILATION SUMMARY" -ForegroundColor Cyan
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "Files Processed: $TotalFiles" -ForegroundColor Gray
    Write-Host "Successful: $SuccessCount" -ForegroundColor Green
    Write-Host "Failed: $($FailedFiles.Count)" -ForegroundColor Red
    Write-Host "Total Errors: $TotalErrors" -ForegroundColor $(if ($TotalErrors -gt 0) { "Red" } else { "Green" })
    Write-Host "Total Warnings: $TotalWarnings" -ForegroundColor $(if ($TotalWarnings -gt 0) { "Yellow" } else { "Green" })
    
    if ($FailedFiles.Count -gt 0) {
        Write-Host ""
        Write-Host "Failed Files:" -ForegroundColor Red
        $FailedFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
        Write-Host ""
        Write-Host "*** $($FailedFiles.Count) FILES FAILED COMPILATION ***" -ForegroundColor Red
    } else {
        Write-Host ""
        Write-Host "*** ALL FILES COMPILED SUCCESSFULLY ***" -ForegroundColor Green
    }
}

# Return exit code
if ($FailedFiles.Count -gt 0) {
    exit 1
} else {
    exit 0
} 