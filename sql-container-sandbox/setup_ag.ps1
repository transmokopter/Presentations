docker compose up -d
Write-Host "Sleeping 15 seconds" -ForegroundColor Cyan
Start-Sleep -Seconds 15

Write-Host "Please key in sa credentials"
$cred = Get-Credential -UserName sa
Invoke-DbaQuery -SqlInstance "localhost,1498" -File $PSScriptRoot\ag_db1.sql -SqlCredential $cred

docker cp db1:/var/opt/mssql/data/db1cert.cer .
docker cp db1:/var/opt/mssql/data/db1cert.pvk . 

docker cp .\db1cert.cer db2:/var/opt/mssql/data
docker cp .\db1cert.pvk db2:/var/opt/mssql/data

Remove-Item db1cert.*

Invoke-DbaQuery -SqlInstance "localhost,1499" -File $PSScriptRoot\ag_db2.sql -SqlCredential $cred

