$ErrorActionPreference = 'Stop'
$since = (Get-Date).AddMonths(-1)
$json = az ad sp list --all -o json
if ($LASTEXITCODE -ne 0) {
  Write-Error "az command failed. Make sure you're logged in and have permission to list service principals."
  exit 1
}
$data = $json | ConvertFrom-Json
$result = @()
foreach ($item in $data) {
  $cd = $item.createdDateTime
  if ($null -eq $cd) { continue }
  if ($cd -is [array]) { $dt = [datetime]$cd[0] } else { $dt = [datetime]$cd }
  if ($dt -ge $since) {
    $result += [pscustomobject]@{
      appId = $item.appId
      displayName = $item.displayName
      objectId = $item.objectId
      createdDateTime = $dt
    }
  }
}
if ($result.Count -gt 0) {
  $result | Sort-Object createdDateTime | Format-Table -AutoSize
} else {
  Write-Output "No service principals found created since $since"
}
