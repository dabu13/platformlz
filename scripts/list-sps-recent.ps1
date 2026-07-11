$ErrorActionPreference='Stop'
$json = az ad sp list --all -o json
if ($LASTEXITCODE -ne 0) { Write-Error 'az command failed'; exit 1 }
$data = $json | ConvertFrom-Json
$result = $data | Where-Object { $_.createdDateTime } | Select-Object displayName,appId,objectId,createdDateTime | Sort-Object @{ Expression = { [datetime]$_.createdDateTime } } -Descending | Select-Object -First 30
if ($result) { $result | Format-Table -AutoSize } else { Write-Output 'No SPs with createdDateTime found.' }