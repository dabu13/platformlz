$ErrorActionPreference='Stop'
$json = az ad sp list --all -o json
if ($LASTEXITCODE -ne 0) { Write-Error 'az command failed'; exit 1 }
$data = $json | ConvertFrom-Json
$result = $data | Where-Object { $_.createdDateTime } | Select-Object displayName,appId,objectId,@{Name='created';Expression={[datetime]$_.createdDateTime}} | Sort-Object created -Descending | Select-Object -First 30
if ($result) { $result | Format-Table -AutoSize } else { Write-Output 'No SPs with createdDateTime found.' }