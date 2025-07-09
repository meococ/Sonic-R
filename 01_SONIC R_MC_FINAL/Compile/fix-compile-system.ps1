# Fix Compilation System Issues
# This script addresses the core problems with the compilation system

param(
    [switch]$AnalyzeOnly = $false
)

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "APEX PULLBACK EA - COMPILATION SYSTEM FIX" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

$ProjectDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Write-Host "Project Directory: $ProjectDir" -ForegroundColor Gray
Write-Host ""

# ISSUE 1: LOG MACRO PARAMETER MISMATCH
Write-Host "=== ISSUE 1: LOG MACRO FIXES ===" -ForegroundColor Yellow

$logMacroFiles = @()
$mqhFiles = Get-ChildItem $ProjectDir -Filter "*.mqh" -Recurse

foreach ($file in $mqhFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Check for LOG_ERROR, LOG_INFO, etc. with 2 parameters
    if ($content -match 'LOG_(ERROR|INFO|WARNING|DEBUG)\s*\(\s*[^,]+\s*,\s*[^)]+\s*\)') {
        $logMacroFiles += $file
        Write-Host "  - $($file.Name): Found LOG macros with 2 parameters" -ForegroundColor Red
    }
}

if (-not $AnalyzeOnly -and $logMacroFiles.Count -gt 0) {
    Write-Host "Fixing LOG macro calls..." -ForegroundColor Green
    
    foreach ($file in $logMacroFiles) {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        
        # Fix LOG_ERROR(logger, msg) -> LOG_ERROR(msg)
        $content = $content -replace 'LOG_ERROR\s*\(\s*[^,]+\s*,\s*([^)]+)\s*\)', 'LOG_ERROR($1)'
        $content = $content -replace 'LOG_INFO\s*\(\s*[^,]+\s*,\s*([^)]+)\s*\)', 'LOG_INFO($1)'
        $content = $content -replace 'LOG_WARNING\s*\(\s*[^,]+\s*,\s*([^)]+)\s*\)', 'LOG_WARNING($1)'
        $content = $content -replace 'LOG_DEBUG\s*\(\s*[^,]+\s*,\s*([^)]+)\s*\)', 'LOG_DEBUG($1)'
        
        Set-Content $file.FullName -Value $content -Encoding UTF8
        Write-Host "    Fixed: $($file.Name)" -ForegroundColor Green
    }
}

# ISSUE 2: INCLUDE PATH PROBLEMS
Write-Host ""
Write-Host "=== ISSUE 2: INCLUDE PATH FIXES ===" -ForegroundColor Yellow

$includeFiles = @()
foreach ($file in $mqhFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Check for wrong include paths
    if ($content -match '#include\s+"\.\.\\') {
        $includeFiles += $file
        Write-Host "  - $($file.Name): Found wrong include paths" -ForegroundColor Red
    }
}

if (-not $AnalyzeOnly -and $includeFiles.Count -gt 0) {
    Write-Host "Fixing include paths..." -ForegroundColor Green
    
    foreach ($file in $includeFiles) {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        
        # Fix ..\ paths to direct paths
        $content = $content -replace '#include\s+"\.\.\\([^"]+)"', '#include "$1"'
        
        Set-Content $file.FullName -Value $content -Encoding UTF8
        Write-Host "    Fixed: $($file.Name)" -ForegroundColor Green
    }
}

# ISSUE 3: MISSING FUNCTION IMPLEMENTATIONS
Write-Host ""
Write-Host "=== ISSUE 3: MISSING IMPLEMENTATIONS ===" -ForegroundColor Yellow

$implementationIssues = @()
foreach ($file in $mqhFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Check for function declarations without implementations
    if ($content -match 'bool\s+Initialize\s*\([^)]*\)\s*;' -and $content -notmatch 'bool\s+Initialize\s*\([^)]*\)\s*\{') {
        $implementationIssues += @{File = $file; Issue = "Missing Initialize implementation"}
    }
}

foreach ($issue in $implementationIssues) {
    Write-Host "  - $($issue.File.Name): $($issue.Issue)" -ForegroundColor Red
}

# ISSUE 4: COMPILE SCRIPT ACCURACY
Write-Host ""
Write-Host "=== ISSUE 4: COMPILE SCRIPT ACCURACY ===" -ForegroundColor Yellow

Write-Host "Problem: .mqh files compile individually but fail when included" -ForegroundColor Red
Write-Host "Solution: Always test with .mq5 files that include the modules" -ForegroundColor Green

# SUMMARY
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

Write-Host "LOG Macro Files: $($logMacroFiles.Count)" -ForegroundColor $(if ($logMacroFiles.Count -gt 0) { "Red" } else { "Green" })
Write-Host "Include Path Files: $($includeFiles.Count)" -ForegroundColor $(if ($includeFiles.Count -gt 0) { "Red" } else { "Green" })
Write-Host "Implementation Issues: $($implementationIssues.Count)" -ForegroundColor $(if ($implementationIssues.Count -gt 0) { "Red" } else { "Green" })

if ($AnalyzeOnly) {
    Write-Host ""
    Write-Host "ANALYSIS COMPLETE - Run without -AnalyzeOnly to fix issues" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "FIXES APPLIED - Test compilation now" -ForegroundColor Green
}

Write-Host "" 