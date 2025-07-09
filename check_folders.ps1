# Script to check duplicate Chiến Lược folders
$basePath = "c:\Users\ADMIN\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\PullBack EA_Trending"

$folders = Get-ChildItem -Path $basePath -Directory | Where-Object {$_.Name -eq "Chiến Lược"}

Write-Host "Found $($folders.Count) folders named 'Chiến Lược'"

for($i = 0; $i -lt $folders.Count; $i++) {
    Write-Host "\n=== Folder $($i+1): $($folders[$i].FullName) ==="
    Write-Host "Created: $($folders[$i].CreationTime)"
    Write-Host "Modified: $($folders[$i].LastWriteTime)"
    Write-Host "Files:"
    Get-ChildItem $folders[$i].FullName -Name | Sort-Object | ForEach-Object { Write-Host "  - $_" }
}