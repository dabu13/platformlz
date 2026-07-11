$ErrorActionPreference='Stop'
$json = az ad sp list --all -o json
if ($LASTEXITCODE -ne 0) { Write-Error 'az command failed'; exit 1 }
$data = $json | ConvertFrom-Json
$data | Where-Object { $_.createdDateTime } | Select-Object displayName,appId,objectId,@{Name='created';Expression={[datetime]$_.createdDateTime}} | Sort-Object created -Descending | Select-Object -First 100 | ConvertTo-Csv -NoTypeInformation | Out-File -Encoding UTF8 .\scripts\sps_recent.csv
Write-Output "Wrote .\scripts\sps_recent.csv with recent SPs (first 100)."