$ErrorActionPreference='Stop'
$since=(Get-Date).AddMonths(-1)
Import-Csv .\scripts\sps_recent.csv | Where-Object { [datetime]$_.created -ge $since } | Select-Object displayName,appId,objectId,created | Format-Table -AutoSize
