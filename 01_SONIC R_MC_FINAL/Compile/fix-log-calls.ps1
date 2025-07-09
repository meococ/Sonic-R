# Fix LOG calls with wrong parameter order
# LOG_INFO(__FUNCTION__, msg) -> LOG_INFO(msg)

param(
    [switch]$AnalyzeOnly = $false
)

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "FIXING LOG CALLS - PARAMETER ORDER" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

$ProjectDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$mqhFiles = Get-ChildItem $ProjectDir -Filter "*.mqh" -Recurse

$fixedFiles = @()

foreach ($file in $mqhFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Fix LOG_INFO(__FUNCTION__, msg) -> LOG_INFO(msg)
    $content = $content -replace 'LOG_INFO\s*\(\s*__FUNCTION__\s*,\s*([^)]+)\)', 'LOG_INFO($1)'
    
    # Fix LOG_ERROR(__FUNCTION__, msg) -> LOG_ERROR(msg)
    $content = $content -replace 'LOG_ERROR\s*\(\s*__FUNCTION__\s*,\s*([^)]+)\)', 'LOG_ERROR($1)'
    
    # Fix LOG_WARNING(__FUNCTION__, msg) -> LOG_WARNING(msg)
    $content = $content -replace 'LOG_WARNING\s*\(\s*__FUNCTION__\s*,\s*([^)]+)\)', 'LOG_WARNING($1)'
    
    # Fix LOG_DEBUG(__FUNCTION__, msg) -> LOG_DEBUG(msg)
    $content = $content -replace 'LOG_DEBUG\s*\(\s*__FUNCTION__\s*,\s*([^)]+)\)', 'LOG_DEBUG($1)'
    
    # Fix cases like LOG_ERROR("msg", __FUNCTION__) -> LOG_ERROR("msg")
    $content = $content -replace 'LOG_ERROR\s*\(\s*([^,]+)\s*,\s*__FUNCTION__\s*\)', 'LOG_ERROR($1)'
    $content = $content -replace 'LOG_INFO\s*\(\s*([^,]+)\s*,\s*__FUNCTION__\s*\)', 'LOG_INFO($1)'
    $content = $content -replace 'LOG_WARNING\s*\(\s*([^,]+)\s*,\s*__FUNCTION__\s*\)', 'LOG_WARNING($1)'
    $content = $content -replace 'LOG_DEBUG\s*\(\s*([^,]+)\s*,\s*__FUNCTION__\s*\)', 'LOG_DEBUG($1)'
    
    if ($content -ne $originalContent) {
        if ($AnalyzeOnly) {
            Write-Host "  - $($file.Name): Found LOG calls to fix" -ForegroundColor Yellow
        } else {
            Set-Content $file.FullName -Value $content -Encoding UTF8
            Write-Host "  - Fixed: $($file.Name)" -ForegroundColor Green
            $fixedFiles += $file.Name
        }
    }
}

Write-Host ""
if ($AnalyzeOnly) {
    Write-Host "ANALYSIS COMPLETE - Run without -AnalyzeOnly to fix" -ForegroundColor Yellow
} else {
    Write-Host "FIXED $($fixedFiles.Count) FILES" -ForegroundColor Green
    foreach ($file in $fixedFiles) {
        Write-Host "  [OK] $file" -ForegroundColor Green
    }
}
Write-Host "" 